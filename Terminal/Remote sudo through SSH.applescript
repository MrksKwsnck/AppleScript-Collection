(* Description: Run getmail script remotely using SSH.
Note: The following project helped a lot in here @ https://github.com/markcarver/mac-ssh-askpass
Author: Markus Kwaśnicki
Date: 2012-01-06 *)

property sshAlias : ""

try
	set shellCommand to "/usr/bin/ssh " & sshAlias & " sudo /Users/redrauscher/Desktop/Admin/getPOPEmails.sh 2>&1" -- The SSH config must be set up correctly
	do shell script shellCommand with administrator privileges
	display dialog "The remote result:" with title "Remote Getmail" default answer result buttons "OK" default button "OK"
on error m number n
	display alert ((n as text) & tab & m) as critical
end try

