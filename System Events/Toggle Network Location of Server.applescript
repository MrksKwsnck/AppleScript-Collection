(*
 * Author:	Markus Kwaśnicki
 * Date:		2011-01-06
 * Description: Changing the current network location between preconfigured locations.
 *)

tell application "System Events"
	tell network preferences
		set locationDTAG to "DTAG"
		set locationDTStAG to "DTStAG"
		set currentLocation to missing value
		set previousLocation to missing value
		
		if name of current location is locationDTAG then
			set previousLocation to locationDTAG
			do shell script "scselect '" & locationDTStAG & "'"
			set currentLocation to locationDTStAG
		else if name of current location is locationDTStAG then
			set previousLocation to locationDTStAG
			do shell script "scselect '" & locationDTAG & "'"
			set currentLocation to locationDTAG
		else
			set previousLocation to name of current location
			do shell script "scselect '" & locationDTStAG & "'"
			set currentLocation to locationDTStAG
		end if
		
		log "Previous location: " & previousLocation
		log "Current location: " & currentLocation
		
		display dialog "Changed network location to: " & currentLocation buttons {"OK"}
	end tell
end tell
