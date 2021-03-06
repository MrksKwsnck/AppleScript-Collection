(* Description: Restart Rails Application Servers 1 and 2 of redpeppix. project hosting.
Author: Markus Kwaśnicki
Date: 2012-01-13 *)

(* Set your ssh configs below *)
property server1_ssh_config : ""
property server2_ssh_config : ""

try
	set shellCommand to "/usr/bin/ssh " & server1_ssh_config & " touch /home/deploy/redpeppix/tmp/restart.txt"
	log "`" & shellCommand & "`"
	do shell script shellCommand
	
	set shellCommand to "/usr/bin/ssh " & server2_ssh_config & " touch /home/deploy/redpeppix/tmp/restart.txt"
	log "`" & shellCommand & "`"
	do shell script shellCommand
	
	say "redpeppix live servers have been touched!" without waiting until completion
	display dialog "redpeppix. live servers have been touched!" with title "Remote restart" buttons {"OK"} default button "OK" with icon 1
on error m number n
	beep
	display dialog m with title n buttons {"OK"} default button "OK" with icon 0
end try

