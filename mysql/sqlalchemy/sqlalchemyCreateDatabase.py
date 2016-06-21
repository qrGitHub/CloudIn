from sqlalchemy import create_engine

def createDatabase(connection, name):
    engine = create_engine(connection, echo = True)
    engine.execute("create database if not exists " + name)

createDatabase("mysql://root:1qaz2wsx$RFV@223.202.85.75:3306", 'test')
