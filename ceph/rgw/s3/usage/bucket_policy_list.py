#!/usr/bin/env python
#-*- coding:utf-8 -*-

bucket_name = 'lyb'
bucket_policy_list = {
        'SpecificUser': {
            'Version':'2012-10-17',
            'Statement':[{
                'Sid':'SpecificPrincipal',
                'Effect':'Allow',
                'Principal': {'AWS': ['arn:aws:iam:::user/normal']},
                #'Principal': {'CanonicalUser':'64-digit-alphanumeric-value'}, # unsupported yet
                'Action':['s3:GetObject'],
                'Resource':['arn:aws:s3:::%s/*' % bucket_name ]
            }]
        },
        'AnonymousRead': {
            'Version':'2012-10-17',
            'Statement':[{
                'Sid':'AnonymousRead',
                'Effect':'Allow',
                'Principal': '*',
                'Action':['s3:GetObject'],
                'Resource':['arn:aws:s3:::%s/*' % bucket_name ]
            }]
        },
        'SpecificIPv4': {
            'Version': '2012-10-17',
            'Id': 'SpecificIPv4',
            'Statement': [
                {
                    'Sid': 'SpecificIPv4',
                    'Effect': 'Allow',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'IpAddress': {'aws:SourceIp': ['10.3.0.0/24', '172.16.1.5/32']},
                        'NotIpAddress': {'aws:SourceIp': '10.3.0.101/32'}
                    }
                }
            ]
        },
        'PreventHotLinkingAllowNull': {
            'Version': '2012-10-17',
            'Id': 'PreventHotLinking',
            'Statement': [
                {
                    'Sid': 'Allow get requests referred by specific IP',
                    'Effect': 'Allow',
                    'Principal': '*',
                    'Action': ['s3:GetObject'],
                    'Resource': [
                        'arn:aws:s3:::%s/*' % bucket_name
                    ],
                    'Condition': {
                        'StringLike': {'aws:Referer': ['http://192.168.63.23*']},
                        'StringNotLike': {'aws:Referer': ['http://192.168.63.233*']}
                    }
                },
                {
                    'Sid': 'Explicit deny to ensure requests are allowed only from specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:*',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'StringNotLike': {'aws:Referer': ['http://192.168.63.23*']}
                    }
                }
            ]
        },
        'PreventHotLinkingDenyNull1': {
            'Version': '2012-10-17',
            'Id': 'PreventHotLinking',
            'Statement': [
                {
                    'Sid': 'Allow get requests referred by specific IP',
                    'Effect': 'Allow',
                    'Principal': '*',
                    'Action': ['s3:GetObject'],
                    'Resource': [
                        'arn:aws:s3:::%s/*' % bucket_name
                    ],
                    'Condition': {
                        'StringLike': {'aws:Referer': ['http://192.168.63.23*']},
                    }
                },
                {
                    'Sid': 'Explicit deny to ensure requests are allowed only from specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        "Null": {"aws:Referer": "true"}
                    }
                }
            ]
        },
        'PreventHotLinkingDenyNull2': {
            'Version': '2012-10-17',
            'Id': 'PreventHotLinking',
            'Statement': [
                {
                    'Sid': 'Allow get requests referred by specific IP',
                    'Effect': 'Allow',
                    'Principal': '*',
                    'Action': ['s3:GetObject'],
                    'Resource': [
                        'arn:aws:s3:::%s/*' % bucket_name
                    ],
                    'Condition': {
                        'StringLike': {'aws:Referer': ['http://192.168.63.23*']},
                    }
                },
                {
                    'Sid': 'Explicit deny to ensure requests are allowed only from specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'StringNotLikeIfExists': {'aws:Referer': ['http://192.168.63.23*']}
                    }
                }
            ]
        },
        'match_wildcards_bug': {
            'Version': '2012-10-17',
            'Id': 'match_wildcards_bug',
            'Statement': [
                {
                    'Sid': 'Explicit deny for specific referer',
                    'Effect': 'Deny',
                    'Principal': '*',
                    'Action': 's3:GetObject',
                    'Resource': 'arn:aws:s3:::%s/*' % bucket_name,
                    'Condition': {
                        'StringLike': {'aws:Referer': ['http://192.*32*']}
                        #'StringLike': {'aws:Referer': ['http://192.168.63.232*']}
                    }
                }
            ]
        },
}
