(* Description:	Back up Atlassian services such as Jira and Confluence
Dependencies:	https://github.com/markcarver/mac-ssh-askpass
Author:			Markus Kwaśnicki *)

property sshUser : "root"
property sshHost : "server2"
property dumpFolder : POSIX path of (path to desktop folder)
property serviceList : {jira:{service_name:"jira", home_dir:"/var/atlassian/application-data/jira", db_name:"jiradb"}, confluence:{service_name:"confluence", home_dir:"/var/atlassian/application-data/confluence", db_name:"confluence"}}

try
	choose from list {"jira", "confluence"} with prompt "Which service do you want to dump onto your Desktop?" with title "Atlassian Service Backup"
	if result is not false then
		set selectedItem to first item of result
		
		if selectedItem is equal to "jira" then
			dumpService(jira of serviceList)
		else if selectedItem is equal to "confluence" then
			dumpService(confluence of serviceList)
		end if
	end if
on error m number n
	display alert ((n as text) & tab & m) as critical
end try

on dumpService(service)
	set destinationFolder to createDestinationFolder(service)
	
	(* Back up the service's home directory *)
	try
		display dialog "Do you want to backup the home directory?" with title service_name of service & "_home" with icon caution
		tell application "Terminal"
			activate
			
			set sshAlias to sshUser & "@" & sshHost
			set shellCommand to "/usr/bin/time /usr/bin/scp -pr " & sshAlias & ":" & home_dir of service & space & POSIX path of destinationFolder & service_name of service & "_$(date '+%Y%m%dT%H%M%S')"
			set terminalId to do script shellCommand & " && echo scp: Home directory dumped successfully; logout"
			
			repeat
				if terminalId exists then
					(* Keep waiting until terminal window get closed *)
					delay 1
				else
					exit repeat
				end if
			end repeat
		end tell
	on error m number n
		if n is equal to -128 then -- User cancelled
			(* Simply skip *)
		else
			error m number n
		end if
	end try
	
	(* Back up the service's database *)
	try
		display dialog "Do you want to backup the database?" with title service_name of service & "_db" with icon caution
		tell application "Terminal"
			activate
			
			set sshAlias to sshUser & "@" & sshHost
			set shellCommand to "/usr/bin/time /usr/bin/ssh " & sshAlias & " /usr/bin/sudo -u postgres /usr/bin/pg_dump --format=p " & db_name of service & " --verbose > " & POSIX path of destinationFolder & db_name of service & "_$(date '+%Y%m%dT%H%M%S').sql"
			set terminalId to do script shellCommand & " && echo pg_dump: Database dumped successfully; logout"
			
			repeat
				if terminalId exists then
					(* Keep waiting until terminal window get closed *)
					delay 1
				else
					exit repeat
				end if
			end repeat
			
		end tell
	on error m number n
		if n is equal to -128 then -- User cancelled
			(* Simply skip *)
		else
			error m number n
		end if
	end try
end dumpService

(* Create destination folder *)
on createDestinationFolder(service)
	set destinationFolder to missing value
	try
		tell application "Finder"
			set destinationFolder to (make new folder at (path to desktop folder) with properties {name:service_name of service}) as alias
		end tell
	on error m number n
		if n is equal to -48 then -- Folder already exists
			set destinationFolder to (path to desktop folder as text) & service_name of service & ":" as alias
		else
			error m number n
		end if
	end try
	return destinationFolder
end createDestinationFolder
