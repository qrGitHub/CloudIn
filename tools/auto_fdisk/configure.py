#!/usr/bin/env python
#-*- coding:utf-8 -*-

import sys, ConfigParser

class Config:
    def __init__(self, path):
        self.path = path
        self.cf = ConfigParser.ConfigParser()
        self.cf.read(self.path)

    def get(self, field, key):
        value = ""
        try:
            value = self.cf.get(field, key)
        except Exception, e:
            sys.stderr.write("Get [%s, %s] from %s abnormally: %s\n" % (field, key, self.path, str(e)))

        return value

    def set(self, field, key, value):
        try:
            self.cf.set(field, key, value)
            self.cf.write(open(self.path, 'w'))
        except Exception, e:
            sys.stderr.write("Set [%s, %s, %s] to %s abnormally: %s\n" %
                    (field, key, value, self.path, str(e)))
            return False

        return True

    def sections(self):
        return self.cf.sections()

    def has_option(self, field, key):
        return self.cf.has_option(field, key)

cfg = Config("./partition.ini")
