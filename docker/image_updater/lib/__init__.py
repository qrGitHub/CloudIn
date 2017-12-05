#!/usr/bin/env python
#-*- coding:utf-8 -*-

from oslo_config import cfg

devops_lib_grp = cfg.OptGroup(name = 'lib', title = 'devops_lib_grp')
CONF = cfg.CONF
CONF.register_group(devops_lib_grp)

devops_console_opts = [ cfg.StrOpt('consoleURL'), cfg.IntOpt('consoleRetryCount') ]
CONF.register_opts(devops_console_opts, group = devops_lib_grp)

devops_docker_opts = [ cfg.StrOpt('storagePath'), cfg.IntOpt('dockerRetryCount') ]
CONF.register_opts(devops_docker_opts, group = devops_lib_grp)
