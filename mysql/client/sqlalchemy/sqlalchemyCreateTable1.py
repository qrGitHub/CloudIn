#!/usr/bin/env python
#-*-coding:utf-8 -*-

from sqlalchemy.dialects.mysql import BIGINT, DATETIME, INTEGER, VARCHAR, ENUM
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine, Column

Base = declarative_base()

class CommandItem(Base):
    __tablename__ = 'commandItem'
    cmd_id = Column(BIGINT, nullable = False, primary_key = True, autoincrement = True)

    parent_account = Column(VARCHAR(64), nullable = False)
    child_account = Column(VARCHAR(64), nullable = True)
    cmd_type = Column(VARCHAR(32), nullable = False)
    extra_info = Column(VARCHAR(128), nullable = True)

    arrive_time = Column(DATETIME, nullable = False)
    finish_time = Column(DATETIME, nullable = True)

    ret_code = Column(INTEGER, nullable = True)
    message = Column(VARCHAR(128), nullable = True)

class JumpserverItem(Base):
    __tablename__ = 'jumpserverItem'
    parent_account = Column(VARCHAR(64), nullable = False, primary_key = True)
    uuid = Column(VARCHAR(64), nullable = False)
    ip = Column(VARCHAR(16), nullable = False)

if __name__ == "__main__":
    engine = create_engine("mysql://root:1qaz2wsx$RFV@223.202.85.75:3306/test", echo = True)
    CommandItem.metadata.create_all(engine)
