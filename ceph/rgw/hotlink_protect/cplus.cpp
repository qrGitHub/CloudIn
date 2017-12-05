#include <arpa/inet.h>
#include <iostream>
#include <cstring>
#include <bitset>
#include <iomanip>
using namespace std;

/*
 * union的各个成员共用一段内存，1是数据的低位
 *      如果data.ch != 1，说明1被存储在data的高地址，就是大端模式；
 *      如果data.ch == 1，说明1被存储在data的低地址，就是小端模式；
 */
void littleORbig() {
    union {
        int n;
        char ch;
    } data;

    data.n = 0x00000001;
    if (data.ch != 1) {
        cout << "Big-endian\n";
    } else {
        cout << "Little-endian\n";
    }
}

// 将字符串类型的IPv4地址转换成二进制格式（网络字节序）
int ipv4_s2n(const string& ip) {
    struct in_addr ia;

    int ret = inet_pton(AF_INET, ip.c_str(), &ia);
    if (ret != 1) {
        cout << "Transfer IPv4 to binary failed with " << ret << endl;
        return 1;
    }

    cout << " s_addr=0x" << hex << setw(8) << setfill('0') << htonl(ia.s_addr) << endl;
    return 0;
}

// 将字符串类型的IPv6地址转换成二进制格式（网络字节序）
int ipv6_s2n(const string& ip) {
    struct in6_addr ia;

    int ret = inet_pton(AF_INET6, ip.c_str(), &ia);
    if (ret != 1) {
        cout << "Transfer IPv6 to binary failed with " << ret << endl;
        return 1;
    }

    cout << "s6_addr=0x";
    for (int i = 0; i < 16; i++) {
        cout << hex << setw(2) << setfill('0') << uint16_t(ia.s6_addr[i]);
    }
    cout << endl;

    return 0;
}

// 将二进制格式的IPv4地址转换成可打印格式
void ipv4_n2p(struct in_addr &ia) {
    char buf[INET_ADDRSTRLEN];

    inet_ntop(AF_INET, &(ia.s_addr), buf, INET_ADDRSTRLEN);
    cout << buf << endl;
}

// 将二进制格式的IPv6地址转换成可打印格式
void ipv6_n2p(struct in6_addr ia) {
    char buf[INET6_ADDRSTRLEN];

    inet_ntop(AF_INET6, &(ia.s6_addr), buf, INET6_ADDRSTRLEN);
    cout << buf << endl;
}

using Address = std::bitset<128>;
struct MaskedIP {
    bool v6;
    Address addr;
    // Since we're mapping IPv6 to IPv4 addresses, we may want to
    // consider making the prefix always be in terms of a v6 address
    // and just use the v6 bit to rewrite it as a v4 prefix for
    // output.
    unsigned int prefix;

    void display() {
        cout << "v6=" << v6 << "\naddr=" << addr << "\nprefix=" << prefix << endl;
    }
};

struct MaskedIP as_network(const string& s) {
    MaskedIP m;

    if (s.empty()) {
        return m;
    }

    m.v6 = string::npos == s.find(':') ? 0 : 1;
    auto slash = s.find('/');
    if (slash == string::npos) {
        m.prefix = m.v6 ? 128 : 32;
    } else {
        char* end = 0;
        m.prefix = strtoul(s.data() + slash + 1, &end, 10);
        if (*end != 0 || (m.v6 && m.prefix > 128) ||
                (!m.v6 && m.prefix > 32)) {
            return m;
        }
    }

    string t;
    auto p = &s;

    if (slash != string::npos) {
        t.assign(s, 0, slash);
        p = &t;
    }

    if (m.v6) {
        struct sockaddr_in6 a;
        if (inet_pton(AF_INET6, p->c_str(), &(a.sin6_addr)) != 1) {
            return m;
        }

        m.addr |= Address(a.sin6_addr.s6_addr[0]) << 0;
        m.addr |= Address(a.sin6_addr.s6_addr[1]) << 8;
        m.addr |= Address(a.sin6_addr.s6_addr[2]) << 16;
        m.addr |= Address(a.sin6_addr.s6_addr[3]) << 24;
        m.addr |= Address(a.sin6_addr.s6_addr[4]) << 32;
        m.addr |= Address(a.sin6_addr.s6_addr[5]) << 40;
        m.addr |= Address(a.sin6_addr.s6_addr[6]) << 48;
        m.addr |= Address(a.sin6_addr.s6_addr[7]) << 56;
        m.addr |= Address(a.sin6_addr.s6_addr[8]) << 64;
        m.addr |= Address(a.sin6_addr.s6_addr[9]) << 72;
        m.addr |= Address(a.sin6_addr.s6_addr[10]) << 80;
        m.addr |= Address(a.sin6_addr.s6_addr[11]) << 88;
        m.addr |= Address(a.sin6_addr.s6_addr[12]) << 96;
        m.addr |= Address(a.sin6_addr.s6_addr[13]) << 104;
        m.addr |= Address(a.sin6_addr.s6_addr[14]) << 112;
        m.addr |= Address(a.sin6_addr.s6_addr[15]) << 120;
    } else {
        struct sockaddr_in a;
        if (inet_pton(AF_INET, p->c_str(), &(a.sin_addr)) != 1) {
            return m;
        }
        m.addr = ntohl(a.sin_addr.s_addr);
    }

    return m;
}

int main() {
    //string input = "121.69.56.174/20";
    //string input = "2001:DB8:1234:5678:ABCD::/80";
    string input = "2001:DB8:1234:5678:ABCD::";

	struct MaskedIP ret = as_network(input);
    ret.display();

    //ipv4_s2n("121.69.56.174");
    //ipv6_s2n("2001:DB8:1234:5678:ABCD::");
    //littleORbig();

    return 0;
}

// g++ -std=c++11 cplus.cpp
