
SELECT 
    USER_NAME(dp.grantee_principal_id) AS 'Grantee'
       , p.type_desc 
  , USER_NAME(dp.grantor_principal_id) AS 'Grantor'
  , CASE dp.class
      WHEN 0 THEN 'Database::' + DB_NAME()
      WHEN 1 THEN OBJECT_NAME(dp.major_id)
      WHEN 3 THEN 'Schema::' + SCHEMA_NAME(dp.major_id) END AS 'Securable'
       , dp.state_desc AS 'Permission'
  , dp.permission_name AS 'Action'       
       , CASE dp.class
           WHEN 0 
                           THEN
                                  CASE 
                                         WHEN p.type = 'G' AND dp.permission_name = 'CONNECT' -- WINDOWS_GROUP AND CONNECT
                                         THEN 'IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'''
                                                       + REPLACE(USER_NAME(dp.grantee_principal_id),'SHERMAN\','SMS\')+''')'
                                                       + ' CREATE USER ['+ REPLACE(USER_NAME(dp.grantee_principal_id),'SHERMAN\','SMS\')
                                                       + '] FOR LOGIN ['+ REPLACE(USER_NAME(dp.grantee_principal_id),'SHERMAN\','SMS\')                                   
                                                       + '] ;'
                                         WHEN p.type = 'U' AND dp.permission_name = 'CONNECT' -- WINDOWS_USER AND CONNECT
                                         THEN 'IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'''
                                                       + REPLACE(USER_NAME(dp.grantee_principal_id),'SHERMAN\','SMS\')+''')'
                                                       + ' CREATE USER ['+ REPLACE(USER_NAME(dp.grantee_principal_id),'SHERMAN\','SMS\')
                                                       + '] FOR LOGIN ['+ REPLACE(USER_NAME(dp.grantee_principal_id),'SHERMAN\','SMS\')                                   
                                                       + '] WITH DEFAULT_SCHEMA=[' + p.default_schema_name COLLATE SQL_Latin1_General_CP1_CI_AS +'];'
                                         ELSE dp.state_desc +' '+ dp.permission_name 
                                              + ' TO ['+ REPLACE(USER_NAME(dp.grantee_principal_id),'SHERMAN\','SMS\') +'];'
                                  END          
      WHEN 1 THEN dp.state_desc + ' '  + dp.permission_name 
                                 + ' ON [' + SCHEMA_NAME(so.schema_id) + '].[' + OBJECT_NAME(dp.major_id) + '] TO [' 
                                                              + USER_NAME(dp.grantee_principal_id) + '];'
      WHEN 3 THEN --'Schema::' + SCHEMA_NAME(dp.major_id) 
                                 dp.state_desc + ' '  + dp.permission_name 
                                 + ' ON SCHEMA :: [' + SCHEMA_NAME(dp.major_id) + '] TO [' 
                                                              + USER_NAME(dp.grantee_principal_id) + '];'
         END as TSQLscripts
FROM sys.database_permissions dp
LEFT JOIN sys.database_principals p ON dp.grantee_principal_id = p.principal_id
LEFT JOIN sys.objects so ON dp.major_id = so.object_id
WHERE dp.class IN (0, 1, 3)
AND USER_NAME(dp.grantee_principal_id) NOT IN ('public','dbo')
AND dp.minor_id = 0
--AND USER_NAME(dp.grantee_principal_id) like 'SMS\S-APP-RS-'
--AND dp.class = 1 AND OBJECT_NAME(dp.major_id) = 'BAI_ShellpointTransactions_vw'
ORDER BY 6,1; 


