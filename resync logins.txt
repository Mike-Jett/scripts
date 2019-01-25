-- Resync logins


SET NOCOUNT ON
 
DECLARE @user varchar(30),@message varchar(200) 
DECLARE user_cursor CURSOR FOR 
SELECT name
FROM sysusers
where islogin = 1 and issqluser = 1 and name not in ('dbo','guest')
ORDER BY name
 
OPEN user_cursor
 
FETCH NEXT FROM user_cursor 
INTO @user
 
WHILE @@FETCH_STATUS = 0
BEGIN
   
      If exists (Select name from master.dbo.syslogins where name = @user)
       BEGIN
         SELECT @message = 'sp_change_users_login ' + '''' + 'Update_One' + '''' + ',' + '''' +  @user + '''' + ' , ' + '''' + @user + ''''
         select @message
         exec (@message) 
       END
   
  
   -- Get the next user.
   FETCH NEXT FROM user_cursor 
   INTO @user
END
 
CLOSE user_cursor
DEALLOCATE user_cursor
GO