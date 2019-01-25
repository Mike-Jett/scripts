set nocount on

declare @DBName varchar(100)

DECLARE curs CURSOR for SELECT distinct name FROM master.dbo.SYSDATABASES where name =DB_NAME()---Only gets user databases
OPEN CURS
FETCH Next FROM CURS into @dbname

--set @DBName ='ban'

WHILE @@FETCH_STATUS = 0
BEGIN               
   EXEC('SELECT ''IF NOT EXISTS(SELECT 1 FROM ' + @DBName + '..sysusers where name='''''' + sysusers.Name COLLATE
			 Latin1_General_CI_AS + '''''')'' + CHAR(13) +  ''EXEC ' + @DBName +'..sp_grantdbaccess '''''' + syslogins.name + '''''', '''''' + 
			  sysusers.name + ''''''''+ char(10) + ''go''   
               FROM ' + @DBName + '..sysusers sysusers   
               JOIN master..syslogins syslogins           
               ON syslogins.sid = sysusers.sid     
               WHERE issqlrole=0          
               AND sysusers.Name Not in (''Guest'', ''dbo'')      
                        ')      
                 
                       
         --Roles       
             EXEC('
              SELECT ''IF NOT EXISTS(SELECT 1 FROM ' + @DBName + '..sysusers where name='''''' + Name + '''''' and issqlrole=1)'' + 
              CHAR(13) + ''exec ' + @DBName + '..sp_addrole '''''' + Name + '''''', ''''dbo''''''+ char(10) + ''go''   
                        FROM ' + @DBName + '..sysusers    
                                 WHERE issqlrole=1          
                                      AND name not like ''db_%''          
                                       ')   
                        
                                 --Role Members   
                         EXEC
                               ('            
      SELECT ''EXEC ' + @DBName + '..sp_addrolemember '''''' + role.name + '''''', '''''' + member.name + ''''''''+ char(10) + ''go''           
            FROM ' + @DBName + '..sysmembers sysmembers               
              JOIN ' + @DBName + '..sysusers role                 
                ON groupuid=role.uid               
                  JOIN ' + @DBName + '..sysusers member               
                      ON memberuid=member.uid              
                        WHERE member.name<>''dbo''               ')                       
                                     
                                      --Object Permissions           
         EXEC('         
               SELECT ''USE ' + @DBName + ''' + CHAR(13) +         
               ''IF EXISTS(SELECT 1 FROM ' + @DBName + '..sysobjects where name='''''' + o.name COLLATE Latin1_General_CI_AS  + '''''')'' + CHAR(13) +   
                ''GRANT '' + v.name + '' ON '' + ''['' + u2.name + ''.'' + o.name +  '']'' +'' TO ['' + u1.name + '']''    +char(10) + ''go'' 
                  FROM ' + @DBName + '..sysprotects p              
                  JOIN master..spt_values v     
                   ON action = v.number         
                    AND v.type = ''T''        
                    JOIN ' + @DBName + '..sysobjects o         
                     ON o.id = p.id      
                      JOIN ' + @DBName + '..sysusers u1   
   ON u1.uid=p.uid    
  JOIN ' + @DBName + '..sysusers u2               
    ON u2.uid=o.uid            
        WHERE p.id > 100       
               AND protecttype IN  (204,205)      
                       ')                 

      
      FETCH Next FROM CURS into @dbname END      
      
        close curs     DEALLOCATE curs