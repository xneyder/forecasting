#!/usr/bin/python

import cx_Oracle
import base64
import sys
import os
import pandas as pd
import glob
import argparse
from datetime import datetime,timedelta
from LoggerInit import LoggerInit
from threading import Thread



class ManagedDbConnection:
        def __init__(self, DB_USER,DB_PASSWORD,ORACLE_SID,DB_HOST):
                self.DB_USER = DB_USER
                self.DB_PASSWORD = DB_PASSWORD
                self.ORACLE_SID = ORACLE_SID
                self.DB_HOST = DB_HOST

        def __enter__(self):
                try:
                        self.db = cx_Oracle.connect('{DB_USER}/{DB_PASSWORD}@{DB_HOST}/{ORACLE_SID}'.format(DB_USER=self.DB_USER,DB_PASSWORD=self.DB_PASSWORD,DB_HOST=self.DB_HOST,ORACLE_SID=self.ORACLE_SID), threaded=True)
                except cx_Oracle.DatabaseError as e:
                        app_logger.error(e)
                        quit()
                self.cursor = self.db.cursor()
                sqlplus_script="alter session set nls_date_format = 'YYYY-MM-DD HH24:MI'"
                try:
                        self.cursor.execute(sqlplus_script)
                except cx_Oracle.DatabaseError as e:
                        app_logger.error(e)
                        app_logger.error(sqlplus_script[0:900])
                        quit()
                return self.db

        def __exit__(self, exc_type, exc_val, exc_tb):
                if self.cursor:
                        self.cursor.close()
                if self.db:
                        self.db.close()

def th_execute_sql_file(sql_file):
	app_logger=logger.get_logger('th_execute_sql_file {sql_file}'.format(sql_file=os.path.basename(sql_file)))
	app_logger.info('Processing')
	with open(sql_file,'r') as file:
		filedata=file.read()
		for sqlplus_script in [sql for sql in filedata.split(';') if len(sql)>2]:
			with ManagedDbConnection(DB_USER,DB_PASSWORD,ORACLE_SID,DB_HOST) as db:
				cursor=db.cursor()
				type=''
				if 'insert' in sqlplus_script.lower():
					type="inserted"
				elif 'delete' in sqlplus_script.lower():
					type="deleted"
				#Loop from start date to end date day by day for performance
				if '<start_date>' in sqlplus_script.lower():
					today_date=datetime.today()	
					end_date=today_date.replace(day=1,hour=0,minute=0,second=0,microsecond=0)-timedelta(days=1)
					start_date=end_date.replace(day=1)
					for single_date in pd.date_range(start_date,end_date):
						end_date=single_date.replace(hour=23,minute=59)
						t_sqlplus_script=sqlplus_script.replace('<start_date>',single_date.strftime("%Y-%m-%d %H:%M"))
						t_sqlplus_script=t_sqlplus_script.replace('<end_date>',end_date.strftime("%Y-%m-%d %H:%M"))
						try:
							cursor.execute(t_sqlplus_script)
							app_logger.info('{rowcount} Records {type} {single_date}'
								.format(type=type,rowcount=cursor.rowcount,single_date=single_date.strftime("%Y-%m-%d %H:%M")))
							db.commit()
						except cx_Oracle.DatabaseError as e:
							app_logger.error(str(e)+" --- "+t_sqlplus_script.replace('\n',' '))
				else:
					try:
						cursor.execute(sqlplus_script)
						app_logger.info('{rowcount} Records {type}'.format(type=type,rowcount=cursor.rowcount))
						db.commit()
					except cx_Oracle.DatabaseError as e:
						app_logger.error(str(e)+" --- "+sqlplus_script.replace('\n',' '))
					
						
			
def main():
	parser = argparse.ArgumentParser()
	parser.add_argument('-t','--mask',
        help='Mask for the sql file list, for example *.sql',
        type=str)
	args = parser.parse_args()
	if not args.mask:
		mask=os.path.join(SQL_DIR,'*sql')
	else:
		mask=os.path.join(SQL_DIR,args.mask)

	workers=[]
	file_list=glob.glob(mask)
	for sql_file in file_list:
		worker = Thread(target=th_execute_sql_file,args=(sql_file,))
		worker.setDaemon(True)
		worker.start()
		workers.append(worker)

	for worker in workers:
		worker.join()
		
if __name__ == '__main__':
        DB_USER=os.environ['DB_USER']
        DB_PASSWORD=base64.b64decode(os.environ['DB_PASSWORD'])
        ORACLE_SID=os.environ['ORACLE_SID']
        DB_HOST=os.environ['DB_HOST']
	LOG_DIR=os.environ['LOG_DIR']
	LOG_FILE=os.path.join(LOG_DIR,'cell_site_classification.log')
	SQL_DIR=os.path.join(os.path.dirname(os.path.abspath(__file__)),'sql')
	logger=LoggerInit(LOG_FILE,10)
	app_logger=logger.get_logger('{script}'.format(script=sys.argv[0]))
	app_logger.info('Start')
	main()
