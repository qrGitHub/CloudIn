#!/usr/bin/env python
#-*- coding:utf-8 -*-

import requests
import re, time
import json

retryCount = 5

class DockerHub(object):
    def __init__(self, url = None, version = 'v2'):
        self.version = version
        self.url = '{0}/{1}'.format(url or 'https://hub.docker.com', self.version)

    def api_url(self, path):
        return '{0}/{1}/'.format(self.url, path)

    def search(self, term):
        next = None
        resp = requests.get(self.api_url('library'), {'query': term})

        while True:
            if next:
                resp = requests.get(next)

            resp = resp.json()

            for i in resp['results']:
                yield i

            if resp['next']:
                next = resp['next']
                continue

            return

    def getFromUrl(self, url):
        print url
        try:
            for i in range(1, retryCount + 1):
                resp = requests.get(url)
                if 200 == resp.status_code:
                    return 0, resp.json()
                elif 404 == resp.status_code:
                    return 1, 'Url[%s] does not exist' % url

                print "Get from '{0}' for the {1}st time failed[{2}]".format(url, i, resp.status_code)
                time.sleep(5)
        except Exception, e:
            print str(e)
            return 1, "Get from '%s' abnormally" % url

        return 1, "Get from '%s' failed[%d]" % (url, resp.status_code)

    def getRepository(self, name):
        user = 'library'
        if '/' in name:
            user, name = name.split('/', 1)

        #return self.getFromUrl(self.api_url('repositories/{0}/{1}'.format(user, name)))
        return self.getFromUrl(self.api_url('repositories/{0}/?page=7'.format(user)))

    def getLogoUrl(self, full_description, name):
        matchObj = re.match(r'[\s\S]*!\[logo\]\((http.*)\)', full_description)
        if not matchObj:
            print 'Find logo url for {0} failed'.format(name)
            return 1, ''

        return 0, matchObj.group(1)

    def getDockerfileUrl(self, full_description, name, tag):
        matchObj = re.match('[\s\S]*\[.*`{0}`.*\]\((https://github.com/docker-library/' \
                    '{1}/blob/.*/Dockerfile)\)'.format(tag, name), full_description)
        if not matchObj:
            print 'Find docker file url for {0}:{1} failed'.format(name, tag)
            return 1, ''

        # transfer the url from html to text
        url = matchObj.group(1)
        url = url.replace('github.com', 'raw.githubusercontent.com')
        url = url.replace('blob/', '')

        return 0, url

keys_list = ['full_description', 'description', 'star_count', 'pull_count']
if '__main__' == __name__:
    obj = DockerHub()
    ret, res = obj.getRepository('mysql')
    #for key in res.keys():
    #    print '{0}:{1}'.format(key, res[key])
    print res
    #print obj.getLogoUrl(res['full_description'], res['name'])
    #print obj.getDockerfileUrl(res['full_description'], res['name'], '5.6')
    #print res['full_description']
    exit()
    for key in res.keys():
        if key in keys_list:
            print '{0}: {1}'.format(key, res[key])
    #print response['full_description']
    #for item in res:
    #    print json.dumps(json.loads(item), indent = 4)
