(* Description: Remotely dumping MySQL databases over SSH tunneling. 
Dependencies: http://www.latenightsw.com/freeware/XMLTools2/index.html
Author: Markus Kwaśnicki
Date: 2012-06-26 *)

set sharedLibrary to load script file ((path to scripts folder from user domain as text) & "com.redpeppix.applescript.shared.scptd") as alias -- Include shared library

property ssh_alias : missing value
property user_name : missing value
property pass_word : missing value
property database : missing value
property noSshTunnel : missing value
property theHost : missing value

property databases : {}
property databaseCredentials : {}

(* Read and parse XML document *)
set fileHandle to open for access (path to resource "database.xml")
set xmlData to read fileHandle to eof
close access fileHandle
set xmlDocument to parse XML xmlData

(* Iterate over XML document *)
set databases to {}
set databaseCredentials to {}
set counter to 0
repeat with currentElement in (XML contents of xmlDocument)
	set currentDatabase to {database:missing value, ssh_alias:missing value, noSshTunnel:missing value, theHost:missing value, user_name:missing value, pass_word:missing value}
	if XML tag of currentElement is equal to "database" then
		set counter to counter + 1
		set currentDatabaseName to |name| of XML attributes of currentElement as text
		set database of currentDatabase to currentDatabaseName
		copy (counter & space & currentDatabaseName) as text to end of databases
		repeat with currentTag in XML contents of currentElement
			if XML tag of currentTag is equal to "SshAlias" then
				set noSshTunnel of currentDatabase to |noSshTunnel| of XML attributes of currentTag as boolean
				set currentSshAlias to XML contents of currentTag as text
				set ssh_alias of currentDatabase to currentSshAlias
			else if XML tag of currentTag is equal to "Host" then
				set currentHost to XML contents of currentTag as text
				set theHost of currentDatabase to currentHost
			else if XML tag of currentTag is equal to "UserName" then
				set currentUserName to XML contents of currentTag as text
				set user_name of currentDatabase to currentUserName
			else if XML tag of currentTag is equal to "PassWord" then
				set currentPassWord to XML contents of currentTag as text
				set pass_word of currentDatabase to currentPassWord
			end if
		end repeat
	end if
	copy currentDatabase to end of databaseCredentials
end repeat

(* Selecting the database to dump *)
choose from list databases with title "Local dump"
set selectedDatabase to result
if selectedDatabase is not false then
	set selectedDatabase to item (word 1 of first item of result as integer) of databaseCredentials
	set ssh_alias to ssh_alias of selectedDatabase
	set user_name to user_name of selectedDatabase
	set pass_word to pass_word of selectedDatabase
	set database to database of selectedDatabase
	set noSshTunnel to noSshTunnel of selectedDatabase
	set theHost to theHost of selectedDatabase
	
	(* Generating timestamp *)
	set currentDateTime to dateToIso8601(missing value) of sharedLibrary
	set currentDateTime to characters 1 through 19 of currentDateTime as text
	set currentDateTime to textReplace("-", "", currentDateTime) of sharedLibrary
	set currentDateTime to textReplace(":", "", currentDateTime) of sharedLibrary
	
	(* Make it so *)
	display dialog "About to dump database " & database & "! This will take a while…" with title "Point of No Return" with icon caution
	try
		if noSshTunnel is false then
			set databaseFileName to database & "_" & currentDateTime & ".sql.gz"
			
			(* Dump database to remote temporary directory *)
			set command to "/usr/bin/ssh " & ssh_alias & " '/usr/bin/mysqldump --user=" & user_name & " --password=" & pass_word & space & database & " | /bin/gzip --stdout > /tmp/" & databaseFileName & "'"
			log command
			do shell script command
			
			(* Download database dump to local Downloads folder *)
			set command to "/usr/bin/scp " & ssh_alias & ":/tmp/" & databaseFileName & space & POSIX path of (path to downloads folder from user domain)
			log command
			do shell script command
			
			(* Remove database dump from remote temporary directory *)
			set command to "/usr/bin/ssh " & ssh_alias & " /bin/rm /tmp/" & databaseFileName
			log command
			do shell script command
		else
			(* Dump database to local temporary directory *)
			set command to "/usr/local/bin/mysqldump --host=" & theHost & " --user=" & user_name & " --password=" & pass_word & space & database & " | /usr/bin/gzip --stdout > " & POSIX path of (path to downloads folder) & database & "_" & currentDateTime & ".sql.gz"
			log command
			do shell script command
		end if
		
		beep
		display dialog "Database " & database & " has been dumped to the downloads folder!" with title "Well done" buttons {"OK"} default button "OK" with icon note
		tell application "Finder" to open (path to downloads folder from user domain)
	on error m number n
		beep
		display dialog m with title n buttons {"OK"} default button "OK" with icon stop
	end try
end if
