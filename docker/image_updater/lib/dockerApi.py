#!/usr/bin/env python
#-*- coding:utf-8 -*-

from docker import Client
import json

from lib.network import downloadFromUrl
from common import log

import requests
import re, time

from consoleApi import pushRegistryImage
from oslo_config import cfg

LOG = log.getLogger(__name__)

CONF = cfg.CONF
retryCount = CONF.lib.dockerRetryCount
storagePath = CONF.lib.storagePath

class DockerHub(object):
    def __init__(self, url = None, version = 'v2'):
        self.version = version
        self.url = '{0}/{1}'.format(url or 'https://hub.docker.com', self.version)

        self.client = Client(base_url = 'unix:///var/run/docker.sock')

    def apiUrl(self, path):
        return '{0}/{1}'.format(self.url, path)

    def getFromUrl(self, url):
        try:
            for i in range(1, retryCount + 1):
                resp = requests.get(url)
                if 200 == resp.status_code:
                    return 0, resp.json()
                elif 404 == resp.status_code:
                    return 1, 'Url[%s] does not exist' % url

                LOG.error("Get from '{0}' for the {1}st time failed[{2}]".format(url, i, resp.status_code))
                time.sleep(5)
        except Exception, e:
            LOG.error(str(e))
            return 1, "Get from '%s' abnormally" % url

        return 1, "Get from '%s' failed[%d]" % (url, resp.status_code)

    def pull(self, name, tag):
        response = self.client.pull(name, tag = tag, stream = True)
        for item in response:
            LOG.debug(json.dumps(json.loads(item), indent = 4))

        return 0

    def push(self, name, tag):
        image_ids = self.client.images(name + ':' + tag, quiet = True)
        if len(image_ids) != 1:
            LOG.error('Get the image id for %s:%s failed[%s]', name, tag, image_ids)
            return 1
        image_id = image_ids[0].split(':')[1]

        LOG.debug("The image id for %s:%s is %s", name, tag, image_id)
        new_name = 'localhost:5000/{0}'.format(name)
        ret = self.client.tag(image_id, new_name, tag)
        if ret != True:
            LOG.error('Tag image %s to %s failed', image_id, new_name)
            return 1

        LOG.debug("Tag image %s to %s:%s succeed", image_id, new_name, tag)
        response = [line for line in self.client.push(new_name, tag = tag, stream = True)]
        #LOG.debug(response)

        return 0

    def getRepositoryInfo(self, name):
        user = 'library'
        if '/' in name:
            user, name = name.split('/', 1)

        return self.getFromUrl(self.apiUrl('repositories/{0}/{1}'.format(user, name)))

    def getRepositoryList(self, totalCount = -1, version = 'v2'):
        path = 'repositories/library'
        repoList = []
        count = 0

        while True:
            ret, res = self.getFromUrl(self.apiUrl(path))
            if 0 != ret:
                LOG.error('Get from %s failed', path)
                return 1, repoList

            for repo in res['results']:
                if count == totalCount:
                    break

                repoList.append(repo)
                count = count + 1

            if not res['next']:
                break
            path = res['next'].split(version + '/')[1]

        return 0, repoList

    def getTagList(self, name, totalCount = -1, version = 'v2'):
        path = 'repositories/library/' + name + '/tags/'
        tagList = []
        count = 0

        while True:
            ret, res = self.getFromUrl(self.apiUrl(path))
            if 0 != ret:
                LOG.error('Get from %s failed', path)
                return 1, tagList

            for repo in res['results']:
                if count == totalCount:
                    break

                tagList.append(repo)
                count = count + 1

            if not res['next']:
                break
            path = res['next'].split(version + '/')[1]

        return 0, tagList

    def getLogoUrl(self, full_description, name):
        matchObj = re.match(r'[\s\S]*!\[logo\]\((http.*)\)', full_description)
        if not matchObj:
            return 1, 'Find logo url for {0} failed'.format(name)

        return 0, matchObj.group(1)

    def getDockerfileUrl(self, full_description, name, tag):
        matchObj = re.match('[\s\S]*\[.*`{0}`.*\]\((https://github.com/.*/Dockerfile)\)'.format(tag), full_description)
        if not matchObj:
            return 1, 'Find docker file url for {0}:{1} failed'.format(name, tag)

        # transfer the url from html to text
        url = matchObj.group(1)
        url = url.replace('github.com', 'raw.githubusercontent.com')
        url = url.replace('blob/', '')

        return 0, url

    def checkIllegal(self, image):
        matchObj = re.match(r'[^\s:]+:[^\s:]+', image)
        if matchObj:
            return 0
        return 1

    def cacheLogo(self, full_description, name):
        ret, url = self.getLogoUrl(full_description, name)
        if ret != 0:
            LOG.error(url)
            return ret, 'None'

        LOG.debug("The logo url for %s is %s", name, url)
        ret, path = downloadFromUrl(url, dirname = storagePath + 'logo', prefix = name)
        if ret != 0:
            LOG.error('Download %s failed[%d]', url, ret)
            return ret, ''

        LOG.debug("Download logo for %s succeed", name)
        return 0, path

    def cacheDockerfile(self, full_description, name, tag):
        ret, url = self.getDockerfileUrl(full_description, name, tag)
        if ret != 0:
            LOG.error(url)
            return ret, 'None'

        LOG.debug("The docker file url for %s:%s is %s", name, tag, url)
        ret, path = downloadFromUrl(url, dirname = storagePath + 'dockerfile', prefix = name + '_' + tag)
        if ret != 0:
            LOG.error('Download %s failed[%d]', url, ret)
            return ret, ''

        LOG.debug("Download docker file for %s:%s succeed", name, tag)
        return 0, path

    def initRepoInfo(self, repoInfo, dockerfilePath, logoPath, tag):
        repoInfo['docker_file'] = dockerfilePath
        repoInfo['icon'] = logoPath
        repoInfo['tag'] = tag

    def cacheImage(self, image):
        name, tag = image.split(':', 1)
        ret, repoInfo = self.getRepositoryInfo(name)
        if ret != 0:
            LOG.error(repoInfo)
            return ret

        ret, logoPath = self.cacheLogo(repoInfo['full_description'], name)
        if ret != 0:
            LOG.error('Cache logo for %s failed[%d]', name, ret)
        else:
            LOG.debug('Cache logo for %s succeed', name)

        ret, dockerfilePath = self.cacheDockerfile(repoInfo['full_description'], name, tag)
        if ret != 0:
            LOG.error('Cache docker file for %s failed[%d]', name, ret)
        else:
            LOG.debug('Cache docker file for %s:%s succeed', name, tag)

        ret = self.pull(name, tag)
        if ret != 0:
            LOG.error('Pull image %s failed[%d]', name, ret)
            return ret

        LOG.debug('Pull image %s:%s succeed', name, tag)
        ret = self.push(name, tag)
        if ret != 0:
            LOG.error('Push image %s to private registry failed[%d]', name, ret)
            return ret

        LOG.debug('Push image %s:%s succeed', name, tag)
        self.initRepoInfo(repoInfo, dockerfilePath, logoPath, tag)
        ret, res = pushRegistryImage(repoInfo)
        if ret != 0:
            LOG.error(res)
            return ret

        LOG.debug('Push image metadata succeed[%s]', res)
        return 0

if '__main__' == __name__:
    obj = DockerHub()
    obj.cacheImage('mysql:5.6')
