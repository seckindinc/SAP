use master
go
sp_helpdevice
go
create database DBNAME on DEVICENAME='4096M'
log on LOGNAME='1024M'
go
use master
go
sp_dboption DBNAME,'trunc log on chkpt',true
go
--DB groups
use DBNAME
go
DBNAME..sp_addgroup GROUPNAME
go
DBNAME..sp_addgroup GROUPNAME
go
--User logins
sp_addlogin USERNAME,'USERNAME',@defdb='tempdb',@passwdexp=0
go
sp_addlogin USERNAME,'USERNAME',@defdb='tempdb',@passwdexp=0
go
--Database users
use DBNAME
go
sp_adduser USERNAME,USERNAME,GROUPNAME
go
sp_adduser USERNAME,USERNAME,GROUPNAME
go
sp_helpdb DBNAME
go
