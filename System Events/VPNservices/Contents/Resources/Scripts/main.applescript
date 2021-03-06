(*
Author:		Markus Kwaśnicki
Date:		2011-11-29
Description:	Establish connection to one of the VPN servers and mount the public folder.
*)

set loadedLibrary to load script file ((path to scripts folder from user domain as text) & "com.redpeppix.applescript.library.scptd") as alias -- Include all handlers

property domain : "com.redpeppix.vpnservices"
property user_name : missing value
property pass_word : missing value
property time_out : 10 -- Timeout in seconds 
property services : {server0:{service_name:"VPN server0", host_name:"192.168.178.2"}, server1:{service_name:"VPN server1", host_name:"192.168.2.4"}, serverW:{service_name:"VPN serverW", host_name:"192.168.2.4"}} -- serverW is used as fallback if server1 fails

try
	set propertyList to getOrCreatePlist(domain) of loadedLibrary
	
	set user_name to getProperty(propertyList, "username") of loadedLibrary
	if user_name is equal to "" then
		do shell script "/usr/bin/whoami"
		set user_name to result
		setProperty(propertyList, "username", user_name) of loadedLibrary
	end if
	
	set pass_word to getProperty(propertyList, "password") of loadedLibrary
	if pass_word is equal to "" then
		display dialog (localized string "TYPE_IN_PASSWORD") default answer "" buttons {(localized string "CANCEL_BUTTON_LABEL"), (localized string "OK_BUTTON_LABEL")} default button (localized string "OK_BUTTON_LABEL") cancel button (localized string "CANCEL_BUTTON_LABEL") with title (localized string "AUTHENTICATION_REQUIRED") with icon note with hidden answer
		set pass_word to text returned of result
		setProperty(propertyList, "password", pass_word) of loadedLibrary
	end if
	
	choose from list {"server0", "server1", "serverW"} with title (localized string "CHOOSE_SERVER")
	if result is not equal to false then
		set chosenService to first item of result
		if chosenService is equal to "server0" then
			set chosenService to server0 of services
		else if chosenService is equal to "server1" then
			set chosenService to server1 of services
		else if chosenService is equal to "serverW" then
			set chosenService to serverW of services
		end if
		-- The service was chosen
		
		tell application "System Events"
			tell current location of network preferences
				set theService to service (service_name of chosenService)
				set isConnected to connected of current configuration of theService -- Try to establish connection
				log "VPN connection established? " & isConnected
				if not isConnected then
					connect theService
					tell me
						activate -- Otherwise the following dialog may keep in the background
						display dialog (textReplace("SECONDS", time_out as text, (localized string "HINT_MESSAGE")) of loadedLibrary) buttons {(localized string "OK_BUTTON_LABEL")} default button (localized string "OK_BUTTON_LABEL") with title (localized string "PLEASE_WAIT") with icon caution giving up after time_out
					end tell
				end if
				set isConnected to connected of current configuration of theService -- Service should be up and running
				log "VPN connection established? " & isConnected
			end tell
		end tell
		
		if isConnected then
			tell application "Finder"
				mount volume "afp://" & user_name & ":" & pass_word & "@" & host_name of chosenService & "/Groups/"
				mount volume "afp://" & user_name & ":" & pass_word & "@" & host_name of chosenService & "/Public/"
				delay 1 -- Wait until the Disks are really mounted
				open disk "Groups"
				open disk "Public"
			end tell
		else
			display dialog (localized string "VPN_KEEP_TRYING") buttons {(localized string "OK_BUTTON_LABEL")} default button (localized string "OK_BUTTON_LABEL") with title (localized string "VPN_NOT_CONNECTED")
		end if
	end if
	-- If result is false then quit script
on error m number n
	display dialog m buttons {(localized string "OK_BUTTON_LABEL")} default button (localized string "OK_BUTTON_LABEL") with title n with icon stop
end try

