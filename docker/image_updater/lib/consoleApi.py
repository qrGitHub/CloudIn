#!/usr/bin/env python
#-*- coding:utf-8 -*-

from oslo_config import cfg
from common import log
import requests, time
import json

LOG = log.getLogger(__name__)

CONF = cfg.CONF
retryCount = CONF.lib.consoleRetryCount
consoleURL = CONF.lib.consoleURL

class encryptRequest(object):
    def post(self, url, data = None):
        if None == data:
            data = {}

        headers = {'content-type': 'application/json'}
        return requests.post(url, data = json.dumps(data), headers = headers)

def postToUrl(url, data):
    try:
        client = encryptRequest()

        for i in range(0, retryCount):
            resp = client.post(url, data = data)
            if 200 == resp.status_code:
                break

            LOG.error("Client post[%s] failed[%d]", url, resp.status_code)
            time.sleep(3)
    except Exception, e:
        LOG.error(str(e))
        return 1, "Post to url[%s] abnormally" % url

    if resp.status_code != 200:
        return 1, "Post to url[%s] failed[%d]" % (url, resp.status_code)

    if resp.json()['ret_code'] != 0:
        return 1, "Post to url[%s] failed[ret_code = %d]" % (url, resp.json()['ret_code'])

    return 0, resp.json()

def pushRegistryImage(image_info, owner = 'usr-31231241', zone = 'ALL'):
    data = {
        "action": 'PushRegistryImage',
        "owner": owner,
        "zone": zone,
        "image_info": image_info
    }

    return postToUrl(consoleURL + "/api/", data)

if __name__ == '__main__':
    image_info = {}
    print pushRegistryImage(image_info)
