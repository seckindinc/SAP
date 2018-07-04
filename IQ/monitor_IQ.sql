select 'drop connection', a.ConnHandle, a.Userid, a.Name, a.TxnID, TempTableSpaceKB, TempWorkSpaceKB, LastReqTime, LastIQCmdTime, ConnCreateTime, numIQCursors, a.IQthreads, NodeAddr,
'drop connection', a.IQconnID, CmdLine
from sp_iqconnection() a, sp_iqcontext() b
where a.ConnHandle=b.ConnHandle 
order by a.TxnID desc


/*
sp_iqlocks
sp_iqcontext
sp_iqtransaction
sp_iqconnection
sp_iqstatus

drop connection 

select * from sp_iqstatus() where Name like '%Other Versions:%'

select C.*,'drop connection',ConnHandle from  DBA.IQ_MPX_STATUS A, sp_iqversionuse() B,sp_iqcontext() C
where A.server_name = 'NIQ03' and A.oldest_version = B.VersionID and B.IqConnId = C.IQConnID
order by ConnOrCurCreateTime

select * from DBA.IQ_MPX_STATUS
exec sp_iqversionuse

SET OPTION Public.Delete_Old_Logs='On'
SET OPTION Public.Delete_Old_Logs='Off'
set option public.IQMSG_LENGTH_MB=2000

sa_server_option 'IQMsgNumFiles',2
sa_server_option 'IQMsgMaxSize',1000
*/
