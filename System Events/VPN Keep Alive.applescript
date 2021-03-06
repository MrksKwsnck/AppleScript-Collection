(* Description: A Script for establishing a predefined VPN connection and trying to keep its session alive.
Author: Markus Kwaśnicki
Date: 2011-11-27 *)

(* Set „LSUIElement“ to YES inside „Info.plist“ file for a daemon like application. *)

property loadedLibrary : load script file ((path to scripts folder from user domain as text) & "com.redpeppix.applescript.shared.scptd") as alias -- Include common handlers

property appDomain : "com.redpeppix.vpn-keep-alive"
property theServiceName : ""
property defaultIdleInterval : 1 -- Seconds until next run

on run
	write2log(appDomain, "Attempting to start VPN connection…") of loadedLibrary
end run

on idle
	set idleInterval to defaultIdleInterval
	
	try
		tell application "System Events"
			(* Hide application like cmd+H keystrike combination *)
			set visible of process ((name of me) as text) to false
		end tell
		
		vpnConnect()
	on error m number n
		write2log(appDomain, "(" & n & ")" & tab & m) of loadedLibrary
		set idleInterval to 15 -- 0 Means 30 seconds being idle (default value)
	end try
	
	return idleInterval
end idle

on quit
	vpnDisconnect()
	continue quit
end quit

on vpnConnect()
	tell application "System Events"
		tell current location of network preferences
			set theService to service theServiceName
			set isConnected to connected of current configuration of theService
			
			if not isConnected then
				connect theService
				delay 5 -- Seconds
				write2log(appDomain, "New VPN connection established!") of loadedLibrary
			end if
		end tell
	end tell
end vpnConnect

on vpnDisconnect()
	tell application "System Events"
		tell current location of network preferences
			set theService to service theServiceName
			set isConnected to connected of current configuration of theService
			
			if isConnected then
				disconnect theService
				write2log(appDomain, "VPN session closed!") of loadedLibrary
			end if
		end tell
	end tell
end vpnDisconnect

(* End of Program*)

