#!/usr/bin/env python
#-*- coding:utf-8 -*-

import requests, os, time
from common import log
#import errno

LOG = log.getLogger(__name__)

retryCount = 5
interval = 3

def downloadFromUrl(url, dirname = './', prefix = None):
    name = os.path.basename(url)
    if prefix:
        name = '{0}_{1}'.format(prefix, name)
    path = os.path.join(dirname, name)

    for i in range(0, retryCount):
        try:
            r = requests.get(url)
            break
        except Exception, e:
            LOG.error("Download from %s failed: %s", url, str(e))

            #LOG.debug("type(e): %s", type(e))
            #LOG.debug("dir(e): %s", dir(e))
            #LOG.debug("type(e.args): %s", type(e.args))
            #LOG.debug("type(e.args[1]): %s", type(e.args[1]))
            #if e.args[1].args[0].errno == errno.ECONNRESET:
            #if e.errno != errno.ECONNRESET:
            if i >= retryCount:
                return 1, ''
            else:
                time.sleep(interval)
                continue

    with open(path, "wb") as fileObj:
        fileObj.write(r.content)

    return 0, path
