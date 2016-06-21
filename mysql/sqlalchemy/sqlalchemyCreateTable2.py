from sqlalchemy.dialects.mysql import BIGINT, DATETIME, INTEGER, VARCHAR
from sqlalchemy import create_engine, Table, Column, MetaData

engine = create_engine("mysql://root:1qaz2wsx$RFV@223.202.85.75:3306/test", echo = True)
metadata = MetaData(engine)

user = Table('commandItem', metadata,
        Column('cmd_id', BIGINT, nullable = False, primary_key = True, autoincrement = True),
        Column('parent_account', VARCHAR(64), nullable = False),
        Column('child_account', VARCHAR(64), nullable = True, default = 'AoA'),
        Column('cmd_type', VARCHAR(32), nullable = False),
        Column('extra_info', VARCHAR(128), nullable = True, default = ''),
        Column('arrive_time', DATETIME, nullable = False),
        Column('finish_time', DATETIME, nullable = True),
        Column('ret_code', INTEGER, nullable = True),
        Column('message', VARCHAR(128), nullable = True))

#user.create(checkfirst = True)

user = Table('jumpserverItem', metadata,
        Column('parent_account', VARCHAR(64), nullable = False, primary_key = True),
        Column('uuid', VARCHAR(64), nullable = False),
        Column('ip', VARCHAR(16), nullable = False))

metadata.create_all(checkfirst = True)
