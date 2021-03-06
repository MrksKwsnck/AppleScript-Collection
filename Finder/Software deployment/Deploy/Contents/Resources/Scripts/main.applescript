(* Install script for deployment of other scripts. 
by Markus Kwaśnicki  
Date: 2012-04-04 *)

try
	set scriptsFolder to path to scripts folder from user domain
	set folderActionScriptsFolder to path to Folder Action scripts folder from user domain
	set applicationsFolder to path to applications folder from user domain
	set workflowsFolder to path to workflows folder from user domain
	set servicesFolder to missing value
	
	tell application "Finder"
		if version begins with "10.7" then
			set servicesFolder to path to services folder from user domain (* Does not exist on Snow Leopard and below *)
		else
			set pathToServicesFolder to path to library folder from user domain -- Must be of alias type
			set nameOfServicesFolder to "Services"
			if not (exists (pathToServicesFolder as text) & nameOfServicesFolder) then
				make new folder at pathToServicesFolder with properties {name:nameOfServicesFolder}
			end if
			set servicesFolder to ((pathToServicesFolder as text) & nameOfServicesFolder) as alias
		end if
	end tell
	
	set deploymentDirectory to "Deployment" -- Folder inside the resource folder of the application bundle package 
	
	-- Items to install
	set scriptsToInstall to {} -- Empty list of records
	
	set currentItem to "com.redpeppix.applescript.shared.scptd"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:scriptsFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "Dateipfad kopieren.workflow"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:servicesFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "fix - Item Owner Rights.scpt"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:folderActionScriptsFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "Flush DNS cache.app"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:applicationsFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "Launch Dashboard.app"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:applicationsFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "LEO Wörterbuch.workflow"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:servicesFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "Nummer wählen (DTStAG).workflow"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:servicesFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "Tea time.app"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:applicationsFolder, itemName:currentItem} to the end of scriptsToInstall
	set currentItem to "What is my WAN IP.app"
	copy {resource:(path to resource currentItem in directory deploymentDirectory), destination:applicationsFolder, itemName:currentItem} to the end of scriptsToInstall
	(* End of items to install *)
	
	tell application "Finder"
		repeat with scriptItem in scriptsToInstall
			try -- to delete items
				(* Move previous versions to the trash 1st *)
				delete (((destination of scriptItem) as text) & (itemName of scriptItem))
				-- If an error was thrown handle it quiet with nothing
			end try
			duplicate (resource of scriptItem) to (destination of scriptItem)
		end repeat
	end tell
	
	set sharedLibrary to load script file ((path to scripts folder from user domain as text) & "com.redpeppix.applescript.shared.scptd") as alias -- Include all handlers
	
	(* Attaching Folder Action Scripts *)
	set TargetFolder to ((path to home folder from user domain as text) & "Public:Drop Box:") as alias
	attachScriptToFolder(TargetFolder, "add - new item alert.scpt") of sharedLibrary
	attachScriptToFolder(TargetFolder, "fix - Item Owner Rights.scpt") of sharedLibrary
	-- End of Attaching
	
	say "Win"
	display dialog "Die Software wurde erfolgreich installiert." buttons {"OK"} default button "OK" with title "WIN"
on error m number n
	say "Fail"
	display dialog "Die Installation der Software ist fehlgeschlagen! (" & n & ": " & m & ")" buttons {"OK"} default button "OK" with title "FAIL"
end try
