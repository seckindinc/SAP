select 'drop connection '+ convert(varchar(20),ConnHandle)+'
go' from sp_iqcontext() where ConnHandle not in(select distinct ConnHandle from sp_iqcontext() where IQGovernPriority <> 'No command' or ConnOrcursor = 'CURSOR')
go
select * from sp_iqdbspace ()
go
select * from sp_iqstatus ()
go
sp_iqhelp
go
sp_iqprocedure
go
sp_iqcheckdb
go
sp_iqcursorinfo
go
sp_iqestspace 
go
select * from sp_iqtransaction()
go 
select * from sp_iqconnection()
go
select * from sp_iqcontext()  
go
select * from sp_iqlocks()
go
sp_iqversionuse
go
sp_iqtablesize
go
sp_iqwho
go
sp_iqtablesize 
go
sp_iqindexinfo
go
sp_iqspaceinfo
go
sp_iqdbsize
go
sp_iqdbspaceinfo
go
sp_iqdbspaceinfo iq_main,
go
sp_iqaddlogin
go
sp_iqpassword
go
sp_helptext sp_iqtabledesc
go
select * from sysusers
go
select * from systable where table_name = 
go
select * from sys.SYSIQTABLE where table_id = 
go
select * from SYS.SYSCOLUMN where table_id = 
go
select * from sysindex where table_id = 
go
select * from sysinfo
go
select * from sysiqfile
go
select * from syslogins where name = 
go
select * from sysoptions
go
select * from sysprocedure
go
select * from sysprocparm
go
select * from sysschedule
go

create procedure DBA.sp_iqtabledesc( @param char(200) )                                                                                                                                                                              
 -- IQ 15/16 compatible                                                                                                                                                                                                                   
 as                                                                                                                                                                                                                           
 declare @user_name char(100)                                                                                                                                                                                                             
 declare @object_name char(200)                                                                                                                                                                                                           
 declare @object_id integer                                                                                                                                                                                                               
 declare @table_id integer                                                                                                                                                                                                                
 declare @split integer                                                                                                                                                                                                                   
 declare @version char(50)                                                                                                                                                                                                                
 select @version = substring(@@version,1,12)                                                                                                                                                                                            
 select @split = charindex('.',@param)                                                                                                                                                                                                  
 if @split = 0                                                                                                                                                                                                                            
   select                                                                                                                                                                                                                                 
     @user_name = user_name(),                                                                                                                                                                                                          
     @object_name = @param                                                                                                                                                                                                                
 else                                                                                                                                                                                                                                     
   select                                                                                                                                                                                                                                 
     @user_name = substring(@param,1,@split-1),                                                                                                                                                                                         
     @object_name = right(@param,datalength(@param)-@split)                                                                                                                                                                           
 if not exists(select 1 from sysobjects as o,sysusers as u where o.name = @object_name and u.name = @user_name and u.uid = o.uid and o.type = 'U')                                                            
   begin                                                                                                                                                                                                                                  
     print '*** ERROR : No such table '+@user_name+'.'+@object_name+' ***'                                                                                                                                                                
     return 1                                                                                                                                                                                                                             
   end                                                                                                                                                                                                                                    
 select @object_id = id from sysobjects as o,sysusers as u where o.uid = u.uid and u.name = @user_name and o.name = @object_name                                                                                
 select @table_id = table_id from systable where object_id = @object_id                                                                                                                                                             
 create table #t(                                                                                                                                                                                                                         
   line varchar(250) not null,                                                                                                                                                                                                          
   )                                                                                                                                                                                                                                      
 insert into #t select 'if exists (select 1 from sysobjects o, sysusers u where o.name='''+@object_name+''' and u.name='''+@user_name+''' and u.uid=o.uid) drop table '+@user_name+'.'+@object_name                                       
     +'go                                                                                                                                                                                                                       ' 
 insert into #t select 'create table '+@user_name+'.'+@object_name+' ('                                                                                                                                                                   
 insert into #t                                                                                                                                                                                                                           
   select '     '+convert(varchar(200),cname)+'    '+case convert(varchar(20),coltype) when 'timestamp' then 'datetime' else convert(varchar(20),coltype) end                                                                     
     +case convert(varchar(20),coltype)                                                                                                                                                                                                 
     when 'char' then '('+convert(varchar(5),length)+')'                                                                                                                                                                                
     when 'varchar' then '('+convert(varchar(5),length)+')'                                                                                                                                                                             
     when 'decimal' then '('+convert(varchar(5),length)+case syslength when 0 then '' else ','+convert(varchar(5),syslength) end+')'                                                                                                
     when 'numeric' then '('+convert(varchar(5),length)+case syslength when 0 then '' else ','+convert(varchar(5),syslength) end+')'                                                                                                
     when 'varbinary' then '('+convert(varchar(5),length)+')' end                                                                                                                                                                       
     +case isnull(default_value,'') when '' then '' else ' default '+default_value end                                                                                                                                              
     +case cs.nulls when 'Y' then ' null' else ' not null' end+','                                                                                                                                                                    
     from sys.syscolumns as cs,sys.syscolumn as c                                                                                                                                                                             
     where c.table_id = @table_id and c.column_id = cs.colno and cs.creator = @user_name and cs.tname = @object_name                                                                                                  
     order by colno asc                                                                                                                                                                                                                 
 insert into #t                                                                                                                                                                                                                           
   select ')go'                                                                                                                                                                                                                       
 insert into #t select 'comment on table '+@user_name+'.'+@object_name+' is '+trim(remarks)                                                                                                                                          
     +'go' from sys.systable where object_id = @object_id and trim(remarks) <> ''                                                                                                                                          
 insert into #t select 'create '+case i.unique when 'Y' then 'UNIQUE ' else '' end+i.index_type+' index '+i.index_name+' on '+@user_name+'.'+@object_name+' ('+ix.colnames                                                
     +')go'                                                                                                                                                                                                                           
     from SYS.SYSINDEX as i,SYS.SYSINDEXES as ix where i.table_id = @table_id and index_owner = 'USER'                                                                                                                  
     and ix.creator = @user_name and ix.tname = @object_name and ix.iname = i.index_name                                                                                                                                  
 if(@version = 'Sybase IQ/16')                                                                                                                                                                                                            
   insert into #t select 'grant '                                                                                                                                                                                                         
       +case selectauth when 'Y' then 'select,' else '' end                                                                                                                                                                             
       +case insertauth when 'Y' then 'insert,' else '' end                                                                                                                                                                             
       +case deleteauth when 'Y' then 'delete,' else '' end                                                                                                                                                                             
       +case updateauth when 'Y' then 'update,' else '' end                                                                                                                                                                             
       +case alterauth when 'Y' then 'alter,' else '' end                                                                                                                                                                               
       +case referenceauth when 'Y' then 'references,' else '' end                                                                                                                                                                      
       +case loadauth when 'Y' then 'load,' else '' end                                                                                                                                                                                 
       +case truncateauth when 'Y' then 'truncate,' else '' end                                                                                                                                                                         
       +' on '+@user_name+'.'+@object_name+' to '+u.name                                                                                                                                                                              
       +'go'                                                                                                                                                                                                                          
       from systableperm as p,sysusers as u                                                                                                                                                                                       
       where p.stable_id = @table_id and u.uid = grantee                                                                                                                                                                        
 else                                                                                                                                                                                                                                     
   insert into #t select 'grant '                                                                                                                                                                                                         
       +case selectauth when 'Y' then 'select,' else '' end                                                                                                                                                                             
       +case insertauth when 'Y' then 'insert,' else '' end                                                                                                                                                                             
       +case deleteauth when 'Y' then 'delete,' else '' end                                                                                                                                                                             
       +case updateauth when 'Y' then 'update,' else '' end                                                                                                                                                                             
       +case alterauth when 'Y' then 'alter,' else '' end                                                                                                                                                                               
       +' on '+@user_name+'.'+@object_name+' to '+u.name                                                                                                                                                                              
       +'go'                                                                                                                                                                                                                          
       from systableperm as p,sysusers as u                                                                                                                                                                                       
       where p.stable_id = @table_id and u.uid = grantee                                                                                                                                                                        
 select * from #t                                                                                                                                                                                                                         
go
