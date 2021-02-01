--mount the following sql under "/docker-entrypoint-initdb.d" directory
--the mysql server container will run scripts in above directory while DB init. 
--
grant all privileges on *.* to john@'%' identified by 'passw0rd' with grant option;
flush privileges;
