#!/usr/bin/env python
#-*- coding:utf-8 -*-

import ConfigParser
import sys, getopt

class Config():
    def __init__(self, path):
        self.path = path
        self.cfp = ConfigParser.ConfigParser(allow_no_value = True)
        self.cfp.read(self.path)

    def set(self, field, key, value):
        try:
            self.cfp.set(field, key, value)
            self.cfp.write(open(self.path, 'w'))
        except Exception, e:
            sys.stderr.write("Set [%s, %s, %s] to %s abnormally: %s\n" %
                    (field, key, value, self.path, str(e)))
            return 1

        return 0

    def has_section(self, section):
        return self.cfp.has_section(section)

    def add_section(self, section):
        try:
            self.cfp.add_section(section)
            self.cfp.write(open(self.path, 'w'))
        except Exception, e:
            sys.stderr.write("Add section[%s] to %s abnormally: %s\n" %
                    (section, self.path, str(e)))
            return 1

        return 0

def usage(cmd):
    print "Usage:\n\tpython {0} -c <config file> -s <section> -k <key> [-v <value>]".format(cmd)
    print "Example:\n\tpython {0} -c /etc/mysql/my.cnf -s client -k port -v 3306".format(cmd)

def checkMandatoryOptions(**optionDic):
    for opt in optionDic:
        if optionDic[opt] == None:
            print "Option '{0}' is missing".format(opt)
            return 1
    return 0

def setSectionKey(**args):
    cfg = Config(args['configFile'])

    if not cfg.has_section(args['section']):
        cfg.add_section(args['section'])
    return cfg.set(args['section'], args['key'], args['value'])

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'c:s:k:v:h', ['help', 'configFile=', 'section=', 'key=', 'value='])
    except getopt.GetoptError, err:
        print str(err)
        print "Try 'python %s -h' for more information." % argv[0]
        return 1

    configFile = section = key = value = None
    for op, val in opts:
        if op in ('-h', '--help'):
            usage(argv[0])
            return 0
        elif op in ('-c', '--configFile'):
            configFile = val
        elif op in ('-s', '--section'):
            section = val
        elif op in ('-v', '--value'):
            value = val
        elif op in ('-k', '--key'):
            key = val
        else:
            print 'Internal error!'
            return 1

    ret = checkMandatoryOptions(configFile = configFile, section = section, key = key)
    if 0 != ret:
        return ret

    if args:
        print 'Parameter "%s" is not needed.' % ' '.join(args)
        return 1

    return setSectionKey(configFile = configFile, section = section, key = key, value = value)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
