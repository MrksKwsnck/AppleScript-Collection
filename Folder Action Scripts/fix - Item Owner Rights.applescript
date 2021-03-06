(* Fixes owner rights issue of Drop Box. Parameters are of type alias for each dopped item into the box.
Author: Markus Kwaśnicki
Date: 2012-04-04 *)

on adding folder items to thisFolder after receiving listOfItems
	tell application "Finder"
		try
			set posixPathOfDropBoxFolder to POSIX path of ((path to public folder from user domain as text) & "Drop Box:")
			set posixPathOfThisFolder to (POSIX path of thisFolder) as text
			
			do shell script "/usr/bin/whoami"
			set currentUsername to result
			
			repeat with currentItem in listOfItems
				set posixPathOfCurrentItem to (POSIX path of currentItem) as text
				
				(* Is the current item an directory? *)
				set testCommand to "/bin/test -d '" & posixPathOfCurrentItem & "'; echo $?"
				do shell script testCommand
				set testResult to result
				set isDirectory to missing value
				if testResult is equal to "0" then
					set isDirectory to true
				else
					set isDirectory to false
				end if
				-- End of Test
				
				set performRecursively to missing value
				if isDirectory then
					set performRecursively to "-R "
				else
					set performRecursively to ""
				end if
				
				(* Looking for invalid owner *)
				do shell script "/usr/bin/stat '" & posixPathOfCurrentItem & "' | /usr/bin/cut -d ' ' -f 5"
				if result is equal to "nobody" then
					display dialog "Please authenticate to fix the Drop Box owner issue." with title "Drop Box owner issue" with icon 2
					set chownCommand to "/usr/sbin/chown -R " & currentUsername & ":staff '" & posixPathOfDropBoxFolder & "'" -- Setting the appropriate owner and the group to staff, for ALL THE items inside the Drop Box
					do shell script chownCommand with administrator privileges
					
					set changeCommand to "/bin/chmod -R +a '" & currentUsername & " allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity' '" & posixPathOfDropBoxFolder & "'" -- Setting ACL for the owner, for ALL THE items inside the Drop Box
					do shell script changeCommand -- I don´t exactly know if administrative privileges are needed here?
					
					exit repeat -- This must be done once only
				end if
			end repeat
		on error m number n
			display dialog m with title n buttons {"OK"} default button "OK" with icon 0
		end try
	end tell
	
	log "com.redpeppix.1337"
end adding folder items to

-- EoF