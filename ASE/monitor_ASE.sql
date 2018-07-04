sp_who
go
select physical_io phy_io,convert(varchar,spid)+'-'+convert(varchar,blocked) 'spid(b)',
substring(status,1,6) status,substring(cmd,1,10) cmd,suser_name(suid) username,
isnull(object_name(id,dbid),'') obj,substring(ipaddr,8,7)+'('+ltrim(rtrim(hostname))+')' ip,execlass,db_name(dbid) dbname,
p.*,'kill',spid from master..sysprocesses p where --suser_name(suid)=''
--db_name(dbid)='' and
--spid=5
p.status not like 'recv%' and suid<>0 and p.spid<>@@spid  
--and db_name(dbid) = 'GMSI'
order by physical_io desc
go
select spid,count(*) lockcount from master..syslocks group by spid
having count(*)>50
go 
--dump tran master with no_log log suspend statusu
set nocount on
declare @dummy int
declare @dummy1 char(100)
select @dummy=spid from master..sysprocesses where status not like 'recv%' and suid<>0 and spid<>@@spid and spid not in
(5259) and physical_io > 10 order by physical_io asc
select @dummy1='exec sp_showplan '+convert(char,@dummy)+',null,null,null'
select @dummy
if (@dummy is not null)
begin
dbcc traceon(3604)
dbcc sqltext(@dummy)
dbcc traceoff(3604)
exec (@dummy1)
end
go

dbcc traceon(3604)
dbcc sqltext(4488)
exec sp_showplan 5135,null,null,null
dbcc traceoff(3604)

select * from master..sysprocesses where spid=

kill 607
