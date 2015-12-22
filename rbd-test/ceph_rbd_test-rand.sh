#!/bin/bash

## Configure all your test host here
physics=(BJ-BGP01-002-01
	     BJ-BGP01-002-02
	     BJ-BGP01-002-03
	     BJ-BGP01-002-04
	     BJ-BGP01-002-05
	     BJ-BGP01-002-06
	     BJ-BGP01-002-07
	     BJ-BGP01-002-08
	     BJ-BGP01-003-01
	     BJ-BGP01-003-02
	     BJ-BGP01-003-04
	     BJ-BGP01-003-05
	     BJ-BGP01-003-07
	     BJ-BGP01-003-08)

IPsFile=hostIPs.txt
if [ ! -f $IPsFile ]; then
	echo "Please prepare all host IPs in $IPsFile"
	exit 1
fi
hosts_all=($(cat $IPsFile))

## Configure your test steps detail
## Each number N means you want do the test with N hosts
#hosts_nums=(2 4 8 12 16 20)
hosts_nums=(${#hosts_all[@]})


## Parameters of fio
ioengine=libaio                 # io engine, could be sync/psync/libaio/...
#size=20                        # Total size of I/O for this job, GB
runtime=600                     # Terminate processing after the specified number of seconds
rate="60m"                      # Cap bandwidth used by this job, the number is in bytes/sec
ratemin=""                      # Tell fio to do whatever it can to maintain at least the given bandwidth
rate_iops="300"                  # Cap the bandwidth to this number of IOPS
rate_iops_min=""                # If this rate of I/O is not met, the job will exit

model_array=("write read")     # rw modele, could be read/write/rw/randread/randwrite/randrw
mixread_array=(50)           # just for fio rw/randrw case
block_array=(4)              # block size
iodepth_array=(8)             # iodepth
numjobs_array=(1)             # number jobs

## Configure how many processes run raised in a host
processes_array=(1)


# Do NOT change below parameters
model=""
mixread=""
block=""
numjobs=""
iodepth=""
processes=""
hosts_array=()


function convert_bw()
{
    local bw=$1

    if [[ $bw == *$bw_unit ]] ; then
        echo $bw | sed -e 's/\([0-9]*[.]*[0-9]*\)\(.*\)/\1/'
    else
        tmp=(`echo $bw | sed -e 's/\([0-9]*[.]*[0-9]*\)\(.*\)/\1 \2/'`)
        value=${tmp[0]}
        unit=${tmp[1]}
        case $bw_unit in
            KB/s)
                case $unit in
                    B/s)
                        echo "scale=2; $value/1024"|bc
                        ;;
                    MB/s)
                        echo "scale=2; $value*1024"|bc
                        ;;
                    *)
                        echo $bw
                        ;;
                esac
                ;;
            *)
                echo $bw
                ;;
        esac
    fi
}

function convert_clat()
{
    local clat=$1

    if [[ $clat == *$clat_unit ]] ; then
        echo $clat | sed -e 's/\([0-9]*[.]*[0-9]*\)\(.*\)/\1/'
    else
        tmp=(`echo $clat | sed -e 's/\([0-9]*[.]*[0-9]*\)\(.*\)/\1 \2/'`)
        value=${tmp[0]}
        unit=${tmp[1]}
        case $clat_unit in
            msec)
                case $unit in
                    usec)
                        echo "scale=2; $value/1000"|bc
                        ;;
                    sec)
                        echo "scale=2; $value*1000"|bc
                        ;;
                    *)
                        echo $clat
                        ;;
                esac
                ;;
            *)
                echo $clat
                ;;
        esac
    fi
}

function do_analyse()
{
    local localfile=$1

    local afiles=(`ls $logdir/$localfile*$processes-*`)
    local filesnum=${#afiles[@]}
    [[ $filesnum -eq 0 ]] && return

    local sumrbw=0
    local sumriops=0
    local sumravg=0
    local sumwbw=0
    local sumwiops=0
    local sumwavg=0

    for onefile in ${afiles[@]} ; do
        local host=`echo $onefile | awk -F '[_.]' '{printf $(NF-2)"_"$(NF-1)}'`
        rbw="/"; riops="/"; ravg="/"; wbw="/"; wiops="/"; wavg="/"
        if [[ $model == *'rw' ]] ; then
            # for rw case
            tmp=`sed -n '/read :/p' $onefile`
            rbw=`echo $tmp | awk -F [,=] '{printf $4}'`
            riops=`echo $tmp | awk -F [,=] '{printf $6}'`
            ravg=`sed -n '/clat (/p' $onefile| sed -n '1p' | awk -F '[,=()]' '{printf $8$2}'`

            tmp=`sed -n '/write:/p' $onefile`
            wbw=`echo $tmp | awk -F [,=] '{printf $4}'`
            wiops=`echo $tmp | awk -F [,=] '{printf $6}'`
            wavg=`sed -n '/clat (/p' $onefile| sed -n '2p' | awk -F '[,=()]' '{printf $8$2}'`
        elif [[ $model == *'read' ]] ; then
            # for read case
            tmp=`sed -n '/read :/p' $onefile`
            rbw=`echo $tmp | awk -F [,=] '{printf $4}'`
            riops=`echo $tmp | awk -F [,=] '{printf $6}'`
            ravg=`sed -n '/clat (/p' $onefile| awk -F '[,=()]' '{printf $8$2}'`
        else
            # for write case
            tmp=`sed -n '/write:/p' $onefile`
            wbw=`echo $tmp | awk -F [,=] '{printf $4}'`
            wiops=`echo $tmp | awk -F [,=] '{printf $6}'`
            wavg=`sed -n '/clat (/p' $onefile| awk -F '[,=()]' '{printf $8$2}'`
        fi

        rbw=$(convert_bw $rbw)
        wbw=$(convert_bw $wbw)
        ravg=$(convert_clat $ravg)
        wavg=$(convert_clat $wavg)

        [[ $rbw != "/" ]] && sumrbw=`echo "scale=2; $sumrbw+$rbw"|bc`
        [[ $riops != "/" ]] && sumriops=`echo "scale=2; $sumriops+$riops"|bc`
        [[ $ravg != "/" ]] && sumravg=`echo "scale=2; $sumravg+$ravg"|bc`
        [[ $wbw != "/" ]] && sumwbw=`echo "scale=2; $sumwbw+$wbw"|bc`
        [[ $wiops != "/" ]] && sumwiops=`echo "scale=2; $sumwiops+$wiops"|bc`
        [[ $wavg != "/" ]] && sumwavg=`echo "scale=2; $sumwavg+$wavg"|bc`

        echo -e "$host\t$model\t$mixread\t$block\t$iodepth\t$numjobs\t$rbw\t$riops\t$ravg\t$wbw\t$wiops\t$wavg" >> $outlog
        echo "$host,$model,$mixread,$block,$iodepth,$numjobs,$rbw,$riops,$ravg,$wbw,$wiops,$wavg" >> $outcsv
    done

    sumravg=`echo "scale=2; $sumravg/$filesnum"|bc`
    sumwavg=`echo "scale=2; $sumwavg/$filesnum"|bc`
    echo "$processes,$model,$mixread,$block,$iodepth,$numjobs,$sumrbw,$sumriops,$sumravg,$sumwbw,$sumwiops,$sumwavg" >> $outsumcsv
}

function do_fio_cmd()
{
    local exec_cmd=$1
    local localfile=$2

    #drop_hosts_caches

    if [[ $option != "-a" ]] ; then
        for host in ${hosts_array[@]} ; do
            local c=0
            while [ $c -lt $processes ] ; do
                local tmp_log=$logdir/${localfile}_${host}_$processes-$c".log"
                c=`expr $c + 1`

                [[ $debug == "true" ]] && echo "ssh $host $exec_cmd > $tmp_log" && continue
                echo "ssh $host $exec_cmd" > $tmp_log
                ssh $host $exec_cmd >> $tmp_log &
            done
        done

        [[ $debug == "true" ]] && return
        # waiting for all the commands finished
        wait
        sleep 10
    fi

    # do analyse
    do_analyse $localfile
}

function log_test_parameters()
{
    local tf_short=`basename $target_file`

    outlog=$logdir/${tf_short}_test_result.log
    outcsv=$logdir/${tf_short}_test_result.csv
    outsumcsv=$logdir/${tf_short}_test_result_summary.csv

    echo "device: $target_file" | tee $outlog $outcsv $outsumcsv
    echo "ioengine: $ioengine runtime: $runtime" | tee -a $outlog $outcsv $outsumcsv
    echo "models: ${model_array[@]}" | tee -a $outlog $outcsv $outsumcsv
    echo "mixread: ${mixread_array[@]}" | tee -a $outlog $outcsv $outsumcsv
    echo "blocks: ${block_array[@]}" | tee -a $outlog $outcsv $outsumcsv
    echo "iodepth: ${iodepth_array[@]}" | tee -a $outlog $outcsv $outsumcsv
    echo "numjobs: ${numjobs_array[@]}" | tee -a $outlog $outcsv $outsumcsv
    echo "processes: ${processes_array[@]}" | tee -a $outlog $outcsv $outsumcsv
    echo "rate: $rate, ratemin: $ratemin" | tee -a $outlog $outcsv $outsumcsv
    echo "rate_iops: $rate_iops, rate_iops_min: $rate_iops_min" | tee -a $outlog $outcsv $outsumcsv
    echo "logdir: $logdir"

    if [[ $# == 1 ]]; then
        for host in ${hosts_array[@]} ; do
            echo -e "$host: \c" | tee -a $outlog $outcsv
            ssh $host "rbd showmapped | grep $tf_short" | tee -a $outlog $outcsv
        done
    else
        echo "host: ${hosts_array[@]}" >> $outsumcsv
    fi

    echo -e "host\tmodel\tmixread\tbs\tiodepth\tnumjobs\tr-bw($bw_unit)\tr-iops\tr-avglat($clat_unit)\tw-bw($bw_unit)\tw-iops\tw-avglat($clat_unit)" >> $outlog
    echo "host,model,mixread,bs,iodepth,numjobs,r-bw($bw_unit),r-iops,r-avglat($clat_unit),w-bw($bw_unit),w-iops,w-avglat($clat_unit)" >> $outcsv
    echo "hosts,model,mixread,bs,iodepth,numjobs,r-bw($bw_unit),r-iops,r-avglat($clat_unit),w-bw($bw_unit),w-iops,w-avglat($clat_unit)" >> $outsumcsv
}

# Drop test hosts caches
function drop_hosts_caches()
{
    local exec_cmd="sync; echo 3 > /proc/sys/vm/drop_caches"

    for host in ${hosts_array[@]} ; do
        [[ $debug == "true" ]] && echo "ssh $host $exec_cmd" && continue
        ssh $host $exec_cmd &
    done
    
    for host in ${physics[@]} ; do
        [[ $debug == "true" ]] && echo "ssh $host $exec_cmd" && continue
        #ssh $host $exec_cmd &
    done

    [[ $debug == "true" ]] && return
    wait
    sleep 10
}

# The main function to do fio command
function do_fio_test_main()
{
    local tf_short=`basename $target_file`

    for processes in ${processes_array[@]} ; do
        for model in ${model_array[@]} ; do
            for block in ${block_array[@]} ; do
                for numjobs in ${numjobs_array[@]} ; do
                    for iodepth in ${iodepth_array[@]} ; do

                        cmd="fio"
                        [[ $option == "" ]] && cmd=${cmd}" -filename=$target_file"
                        [[ $option == "-d" ]] && cmd=${cmd}" -directory=$target_dir"
                        cmd=${cmd}" -thread -group_reporting -direct=1"
                        cmd=${cmd}" -ioengine=$ioengine"
                        cmd=${cmd}" -bs=${block}k"
                        #cmd=${cmd}" -size=${size}G"
                        cmd=${cmd}" -runtime=$runtime"
                        cmd=${cmd}" -numjobs=$numjobs"
                        cmd=${cmd}" -rw=$model"

                        if [[ $ioengine == "libaio" ]]; then
                            cmd=${cmd}" -iodepth=$iodepth"
                            if [[ $model == 'rand'* ]] ; then
                                cmd=${cmd}" -iodepth_batch_submit=1"
                                cmd=${cmd}" -iodepth_batch_complete=1"
                            else
                                cmd=${cmd}" -iodepth_batch_submit=8"
                                cmd=${cmd}" -iodepth_batch_complete=8"
                            fi
                        fi

                        [[ $rate != "" ]] && cmd=${cmd}" -rate=$rate"
                        [[ $ratemin != "" ]] && cmd=${cmd}" -ratemin=$ratemin"
                        [[ $rate_iops != "" ]] && cmd=${cmd}" -rate_iops=$rate_iops"
                        [[ $rate_iops_min != "" ]] && cmd=${cmd}" -rate_iops_min=$rate_iops_min"

                        #echo $model | grep rw > /dev/null
                        if [[ $model == *'rw' ]] ; then
                            # for mix read&write model
                            tmpcmd=$cmd
                            for mixread in ${mixread_array[@]} ; do
                                file=${tf_short}_${model}_${mixread}r_${block}k_${numjobs}n_${iodepth}q
                                cmd=${tmpcmd}" -rwmixread=$mixread"
                                cmd=${cmd}" -name=${model}_${mixread}r_${block}k_${iodepth}q"
                                do_fio_cmd "$cmd" $file
                            done #end mixread
                        else
                            mixread="/"
                            file=${tf_short}_${model}_${block}k_${numjobs}n_${iodepth}q
                            cmd=${cmd}" -name=${model}_${block}k_${iodepth}q"
                            do_fio_cmd "$cmd" $file
                        fi

                    done #end iodepth
                done #end numjobs
            done #end block size
        done #end model
    done #end processes
}

function main()
{
    # Fill the target dev/file if configured
    if [[ $fill_target == "true" ]]; then
        for host in ${hosts_all[@]} ; do
            localcmd="ssh $host 'dd if=/dev/zero of="$target_file" bs=1M' &"
            [[ $debug == "true" ]] && echo $localcmd && continue
            eval $localcmd
        done

        # waiting for all the commands finished
        [[ $debug != "true" ]] && wait
    fi

    # Create log directory
    now=`date +%Y-%m-%d-%H-%M-%S`
    logdir="log/$now"
    mkdir -p log
    mkdir -p $logdir

    local orig_logdir=$logdir
    for nums in ${hosts_nums[@]} ; do
        logdir="$orig_logdir/$nums""-hosts"
        mkdir -p $logdir

        # Initialize the hosts array used by each test cycle
        hosts_array=(${hosts_all[@]:0:$nums})
        echo "${hosts_array[@]}"

        log_test_parameters
        do_fio_test_main
    done

    [[ $debug == "true" ]] && rm -rf $orig_logdir
}

function usage()
{
    echo "usage: $1 <target device/file>        # run fio with -filename=<target device/file>"
    echo "          e.g.: $1 /dev/rbd1          # specify test device"
    echo "                $1 ~/fio_tst_file     # specify test file"
    echo "       $1 -d <target directory>       # run fio with -directory=<target directory>"
    echo "       $1 -a <log_dir>                # analyse the logs in <log_dir>"
}


# main entrance
debug="false"
fill_target="false"
option=""
bw_unit="KB/s"
clat_unit="msec"
outlog=""
outcsv=""
outsumcsv=""

script_name=$0
if [[ $# == 1 ]]; then
    target_file=$1
    if [[ $target_file == "-h" ]]; then
        usage $script_name
        exit
    fi
elif [[ $# == 2 ]]; then
    option=$1
    if [[ $option == "-a" ]]; then
        logdir=$2
        target_file=`ls $logdir | head -n 1 | awk -F [_] '{printf $1}'`

        log_test_parameters
        do_fio_test_main
        exit
    elif [[ $option == "-d" ]]; then
        target_dir=$2
    fi
else
    usage $script_name
    exit
fi

main

