#include <iostream>
#include <cstring>
#include <sys/time.h>
using namespace std;

#define OUT_REPEATE_NUM 100000
#define IN_REPEATE_NUM  60

char s1[] = "abcedfg";
char s2[] = "hijklmn";
char s3[] = "opqrst";

void appendTest1(string& ret)
{
    for(int i = 0; i < IN_REPEATE_NUM; i++) {
        ret.append(s1, 7);
        ret.append(s2, 7);
        ret.append(s3, 6);
    }
}

void appendTest2(string& ret)
{
    for(int i = 0; i < IN_REPEATE_NUM; i++) {
        ret.append(s1, strlen(s1));
        ret.append(s2, strlen(s2));
        ret.append(s3, strlen(s3));
    }
}

void appendTest3(string& ret)
{
    for(int i = 0; i < IN_REPEATE_NUM; i++) {
        ret.append(s1);
        ret.append(s2);
        ret.append(s3);
    }
}

int main() {
    string append1, append2, append3;
    struct timeval sTime, eTime;

    gettimeofday(&sTime, NULL);
    for(int i = 0; i < OUT_REPEATE_NUM; i++) {
        append1 = "";
        appendTest1(append1);
    }
    gettimeofday(&eTime, NULL);
    long AppendTime1 = (eTime.tv_sec-sTime.tv_sec)*1000000+(eTime.tv_usec-sTime.tv_usec); //exeTime 单位是微秒

    gettimeofday(&sTime, NULL);
    for(int i = 0; i < OUT_REPEATE_NUM; i++)
    {
        append2 = "";
        appendTest2(append2);
    }
    gettimeofday(&eTime, NULL);
    long AppendTime2 = (eTime.tv_sec-sTime.tv_sec)*1000000+(eTime.tv_usec-sTime.tv_usec); //exeTime 单位是微秒

    gettimeofday(&sTime, NULL);
    for(int i = 0; i < OUT_REPEATE_NUM; i++)
    {
        append3 = "";
        appendTest3(append3);
    }
    gettimeofday(&eTime, NULL);
    long AppendTime3 = (eTime.tv_sec-sTime.tv_sec)*1000000+(eTime.tv_usec-sTime.tv_usec); //exeTime 单位是微秒

    cout<<"AppendTime1 is : "<<AppendTime1<<endl;
    cout<<"AppendTime2 is : "<<AppendTime2<<endl;
    cout<<"AppendTime3 is : "<<AppendTime3<<endl;
    if (append1 != append2 || append1 != append3) {
        cout << "Result is different!" << endl;
    }

    return 0;
}
