#!/usr/bin/env python
#-*- coding:utf-8 -*-

from fabric.api import run, execute, env, prefix, hide
from clint.textui import puts, columns
import click, simplejson

def _get_rds_list():
    res = run("trove --json list --all")
    res = simplejson.loads(res)
    rds_list = {}
    for rds in res:
        rds_list[rds['name']] = [rds['id'], rds['tenant_id']]

    user_list = _get_user_list()
    for rds in rds_list:
        tanent_id = rds_list[rds][1]
        rds_list[rds][1] = user_list[tanent_id]
    # rds_list = {'rds-id': ['trove-id', 'user-id'], ...}

    return rds_list

def _get_user_list():
    """
    :return: user_list = {'tanent-id': 'user-id', ...}
    """
    result = run("openstack project list -f json")
    result = simplejson.loads(result)

    user_list = {}
    for user in result:
        user_list[user['ID']] = user['Name']

    return user_list

def _print_humanable_result(rds_list):
    puts(columns(['+', 1], ['-'*20, 20], ['+', 1], ['-'*36, 36], ['+', 1], ['-'*12, 12], ['+', 1]))
    puts(columns(['|', 1], ['RDS-NAME', 20], ['|', 1], ['TROVE-ID', 36], ['|', 1], ['USER-ID', 12], ['|', 1]))
    puts(columns(['+', 1], ['-'*20, 20], ['+', 1], ['-'*36, 36], ['+', 1], ['-'*12, 12], ['+', 1]))
    for rds in rds_list:
        puts(columns(['|', 1], [rds[0], 20], ['|', 1], [rds[1][0], 36], ['|', 1], [rds[1][1], 12], ['|', 1]))
    puts(columns(['+', 1], ['-'*20, 20], ['+', 1], ['-'*36, 36], ['+', 1], ['-'*12, 12], ['+', 1]))

def get_userlist():
    with hide('stdout', 'running'):
        with prefix("source /opt/osdeploy/admin_openrc.sh"):
            rds_list = _get_rds_list()
            rds_list = rds_list.items()
            # rds_list = [('rds-name', ['trove-id', 'user-id']), ...]

            rds_list = sorted(rds_list, key = lambda rds: rds[1][1] + rds[0])
            _print_humanable_result(rds_list)
    return 0

@click.command()
@click.option('-p', '--password', default = 'openstack!@#cloudin')
@click.option('-h', '--host', default = 'localhost')
@click.option('-u', '--user', default = 'openstack')
def main(user, host, password):
    """
    \b
         python get_trove_userlist.py --user root --host 127.0.0.1 --password #@!@#
         python get_trove_userlist.py --host 123.59.26.133
         python get_trove_userlist.py --host 123.59.184.133
    """
    env.hosts = '{0}@{1}'.format(user, host)
    env.password = password

    return execute(get_userlist)[env.hosts]

if '__main__' == __name__:
    main()
