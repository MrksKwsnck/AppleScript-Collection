(* Delete files previously deployed items. 
by Markus Kwaśnicki
Date: 2011-12-16 *)

set fileNames to {"com.redpeppix.applescript.library.scptd", "com.redpeppix.applescript.shared.scptd", "Dateipfad kopieren.workflow", "fix - Item Owner Rights.scpt", "Flush DNS.app", "Flush DNS cache.app", "Launch Dashboard.app", "LEO Wörterbuch.workflow", "Nummer wählen (DTStAG).workflow", "Tea time.app", "VPNservices.app", "What is my WAN IP.app"} -- List of previously deployed items

(* Is the applications folder from the user domain existing? *)
set applicationsFolderFromUserDomain to missing value
try
	set applicationsFolderFromUserDomain to path to applications folder from user domain
on error --number -43
	tell application "Finder"
		set applicationsFolderName to missing value
		(*if user locale of (system info) is equal to "de_DE" then
			set applicationsFolderName to "Programme"
		else*)
		set applicationsFolderName to "Applications"
		--end if
		make new folder at (path to home folder) with properties {name:applicationsFolderName}
	end tell
	delay 2
	set applicationsFolderFromUserDomain to path to applications folder from user domain
end try
(* Asuming the existence of the applications folder from the user domain! *)

set folderPaths to {¬
	path to scripts folder from user domain, ¬
	path to scripts folder from local domain, ¬
	path to Folder Action scripts folder from user domain, ¬
	path to Folder Action scripts folder from local domain, ¬
	applicationsFolderFromUserDomain, ¬
	path to applications folder from local domain, ¬
	path to workflows folder from user domain, ¬
	getPathToServicesFolder() of me ¬
	}
return
repeat with folderPath in folderPaths
	repeat with fileName in fileNames
		tell application "Finder"
			try
				delete (folderPath as text) & fileName -- Works without alias and with ordinary text type
			end try
		end tell
	end repeat
end repeat

(* Returns the path to services folder from user domain. *)
on getPathToServicesFolder()
	set servicesFolder to missing value
	
	set OSVersion to missing value
	tell application "Finder"
		set OSVersion to version as text
	end tell
	
	if OSVersion begins with "10.7" or OSVersion begins with "10.8" then
		set servicesFolder to path to services folder from user domain (* Does not exist on Snow Leopard and below *)
		log "This OS is a Lion: " & OSVersion
	else
		tell application "Finder"
			set pathToServicesFolder to path to library folder from user domain -- Must be of alias type
			set nameOfServicesFolder to "Services"
			if not (exists (pathToServicesFolder as text) & nameOfServicesFolder) then
				make new folder at pathToServicesFolder with properties {name:nameOfServicesFolder}
			end if
			set servicesFolder to ((pathToServicesFolder as text) & nameOfServicesFolder) as alias
		end tell
	end if
	
	return servicesFolder
end getPathToServicesFolder
