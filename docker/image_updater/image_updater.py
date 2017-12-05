#!/usr/bin/env python
#-*- coding:utf-8 -*-

from oslo_config import cfg
from common import log
import sys, time

devops_daemon_grp = cfg.OptGroup(name = 'daemon', title = 'devops_daemon_grp')
devops_daemon_opts = [ cfg.IntOpt('interval') ]

CONF = cfg.CONF
CONF.register_group(devops_daemon_grp)
CONF.register_opts(devops_daemon_opts, group = devops_daemon_grp)

LOG = log.getLogger(__name__)

def prepareService(argv = None):
    log_levels = (cfg.CONF.default_log_levels + ['stevedore=INFO'])
    cfg.set_defaults(log.log_opts, default_log_levels = log_levels)
    if argv is None:
        argv = sys.argv
    cfg.CONF(argv[1:], project = 'devops', validate_default_values = True)
    log.setup('devops')

def getIncomingImageList():
    with open('./console_input/incoming_image_list.txt') as fileObj:
        lineList = fileObj.readlines()

    lineList = map(lambda s: s.strip('\n'), lineList)

    return lineList

def findRepositoryType(image):
    return 'DockerHub'

if __name__ == '__main__':
    prepareService()
    from lib.dockerApi import DockerHub

    LOG.debug('Image updater begin')

    while True:
        image_list = getIncomingImageList()
        LOG.debug('Start to cache %d images', len(image_list))
        for image in image_list:
            repositoryType = findRepositoryType(image)
            LOG.debug("The repository type for '%s' is %s", image, repositoryType)
            if 'DockerHub' == repositoryType:
                repositoryObj = DockerHub()
            else:
                LOG.error("Cannot find repository type for '%s'", image)
                continue

            if repositoryObj.checkIllegal(image):
                LOG.error("'%s' is not a legal image", image)
                continue

            try:
                ret = repositoryObj.cacheImage(image)
                if ret != 0:
                    LOG.error("Cache image '%s' failed[%d]", image, ret)
            except Exception, e:
                LOG.error('%s', str(e))
                continue
            except KeyboardInterrupt:
                break
        LOG.debug('Finish caching %d images', len(image_list))

        break #time.sleep(CONF.daemon.interval)

    LOG.debug('Image updater end')
