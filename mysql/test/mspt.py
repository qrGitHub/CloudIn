#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os, time, random, base64
import sys, getopt
import MySQLdb

size = 10000

def executeSql(conn, sql):
    cursor = conn.cursor()
    cursor.execute(sql)
    conn.commit()
    cursor.close()

def executeSqlWithDB(conn, sql, db):
    cursor = conn.cursor()
    cursor.execute('use ' + db)
    cursor.execute(sql)
    conn.commit()
    cursor.close()

def setup(host, port, user, passwd, db):
    conn = MySQLdb.connect(host = host, port = port, user = user, passwd = passwd)

    sql = 'create database {0}'.format(db)
    executeSql(conn, sql)

    sql = """create table if not exists test (
                    id integer not null primary key,
                    age integer not null,
                    name varchar(255) not null)
          """
    executeSqlWithDB(conn, sql, db)

    data = []
    for i in range(size):
        data.append((i, i, base64.b64encode(os.urandom(64))))

    return conn, data

def teardown(conn, db):
    sql = 'drop database if exists {0}'.format(db)
    executeSql(conn, sql)

def insert_one_test(conn, db, data):
    cursor = conn.cursor()
    cursor.execute("use " + db)
    cursor.execute("delete from test")

    start = time.time()
    for value in data:
        cursor.execute('insert into test (id, age, name) values (%s, %s, %s)', value)

    conn.commit()
    cursor.close()

    print "INSERT ONE", time.time() - start

def insert_many_test(conn, db, data):
    cursor = conn.cursor()
    cursor.execute("use " + db)
    cursor.execute("delete from test")

    start = time.time()
    start_index = 0
    batch_amount = 2000
    while start_index < size:
        values = data[start_index: start_index + batch_amount]
        cursor.executemany("insert into test (id, age, name) values (%s, %s, %s)", values)

        start_index += batch_amount

    conn.commit()
    cursor.close()

    print "INSERT MANY", time.time() - start

def query_test(conn, db):
    cursor = conn.cursor()
    cursor.execute("use " + db)

    start = time.time()
    for i in range(size):
        ID = random.randint(0, size - 1)
        cursor.execute("select id, age, name from test where id = %s", (ID,))
        result = cursor.fetchone()
        assert result[1] == ID

    print "QUERY", time.time() - start

def run(conn, db, data):
    insert_one_test(conn, db, data)
    insert_many_test(conn, db, data)
    query_test(conn, db)

def usage(cmd):
    print "Usage:\n\tpython {0} --user <user> --passwd <password> [--host <host>] [--port <port>] [--db <database>] [--size <db size>]".format(cmd)
    print "Example:\n\tpython {0} --user admin --passwd 666 --host 8.8.8.8 --port 3307 --db testMySQL".format(cmd)
    print "\tpython {0} --user admin --passwd 666 --host 8.8.8.8".format(cmd)
    print "\tpython {0} --user admin --passwd 666 --db testMySQL".format(cmd)
    print "\tpython {0} --user admin --passwd 666 --port 3308".format(cmd)
    print "\tpython {0} --user admin --passwd 666 --size 100".format(cmd)
    print "\tpython {0} --user admin --passwd 666".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if None == optionDic[opt]:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def simplePerformanceTest(host, port, user, passwd, db):
    conn, data = setup(host, port, user, passwd, db)
    run(conn, db, data)
    teardown(conn, db)

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'h', ['help', 'host=', 'port=', 'user=', 'passwd=', 'db=', 'size='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    user = passwd = None
    host = 'localhost'
    db   = 'sbtest'
    port = 3306
    global size

    for op, val in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('--host'):
            host = val
        elif op in ('--port'):
            port = val
        elif op in ('--user'):
            user = val
        elif op in ('--passwd'):
            passwd = val
        elif op in ('--db'):
            db = val
        elif op in ('--size'):
            size = int(val)
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(user = user, passwd = passwd)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    return simplePerformanceTest(host, port, user, passwd, db)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
