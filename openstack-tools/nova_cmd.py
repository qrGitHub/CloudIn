import os
import sys
import commands
import time

class NovaCMD(object):
    def parse_list_result(self, output):
        result_list = output.split('\n')
        field_name = {}
        tokens = result_list[1].split('|')
        for i in range(0, len(tokens)):
            field_name[i] = tokens[i].strip()
        info_list = []
        for result in result_list[3:-1]:
            info = {}
            tokens = result.strip().split('|')
            for i in range(1, len(tokens) - 1):
                info[field_name[i]] = tokens[i].strip()
            info_list.append(info)
        return info_list

    def cmd(self, cmd):
        status, output = commands.getstatusoutput(cmd)
        if cmd.find('list') != -1:
            return self.parse_list_result(output)
        else:
            return status == 0

    def cache_image(self):
        image_list = self.cmd('nova image-list')
        net_list = self.cmd('nova net-list')
        flavor_list = self.cmd('nova flavor-list')
        hypervisor_list = self.cmd('nova hypervisor-list')
        net = net_list[0]
        for n in net_list:
            if n['Label'] == 'base-net':
                net = n
                break
        flavor = flavor_list[0]
        for f in flavor_list:
            if f['Name'] == 'm1.medium':
                flavor = f
                break
        # every host
        for hypervisor in hypervisor_list:
            if hypervisor['State'] == 'up' and hypervisor['Status'] == 'enabled':
                # every image
                for image in image_list:
                    md = "nova boot \'cache_image_" + image['Name'] + "\' --flavor " + flavor['ID'] + " --image " + image['ID'] + " --nic net-id=" + net['ID']  + " --availability-zone nova:" + hypervisor['Hypervisor hostname']
                    print md
                    return
                    status, output = commands.getstatusoutput(md)
                    print md
                    print output

    def delete_cache_instance(self):
        # delete after ACTIVE
        while True:
            all_instances_are_deleted = True
            instance_list = self.cmd('nova list')
            for instance in instance_list:
                if instance['Status'] == 'ACTIVE' and instance['Name'].find('cache') != -1:
                    all_instances_are_deleted = False
                    self.cmd('nova delete ' + instance['ID'])
            if all_instances_are_deleted:
                print "cache images done"
                break
            time.sleep(10)

    def delete_error_instance(self):
        # delete after ERROR
        while True:
            all_instances_are_deleted = True
            instance_list = self.cmd('nova list --all')
            for instance in instance_list:
                if instance['Status'] == 'ERROR':
                    all_instances_are_deleted = False
                    self.cmd('nova delete ' + instance['ID'])
            if all_instances_are_deleted:
                print "cache images done"
                break
            time.sleep(10)


if __name__ == '__main__':
    nova_cmd = NovaCMD()
    cmd = 'nova_cmd.' + sys.argv[1] + '()'
    eval(cmd)
