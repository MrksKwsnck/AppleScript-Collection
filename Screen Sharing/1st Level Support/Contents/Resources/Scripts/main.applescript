(* 1st Level Support
Dependencies:
• http://www.latenightsw.com/freeware/XMLTools2/index.html
• http://www.latenightsw.com/freeware/RecordTools/index.html
Author: Markus Kwaśnicki
Date: 2012-07-10 *)

set sharedLibrary to load script file ((path to scripts folder from user domain as text) & "com.redpeppix.applescript.library.scptd") as alias -- Include all handlers

property people : {}

(* Read and parse XML document *)
set fileHandle to open for access (path to resource "network_nodes_accounts.xml")
set xmlData to read fileHandle to eof as «class utf8»
close access fileHandle
set xmlDocument to parse XML xmlData

(* Iterate over XML document *)
set people to {}
set counter to 0
repeat with currentElement in (XML contents of xmlDocument)
	set currentPerson to {theName:missing value, theIp:missing value}
	if XML tag of currentElement is equal to "Node" then
		set counter to counter + 1
		set theIp of currentPerson to |ip| of XML attributes of currentElement
		repeat with currentChild in XML contents of currentElement
			if XML tag of currentChild is equal to "Account" then
				set theName of currentPerson to (|name| of XML attributes of currentChild)
				log theName of currentPerson
			end if
		end repeat
	end if
	copy currentPerson to end of people
end repeat

(* Merging lists *)
set theNames to getAttributeListFromSublist(people, "theName") of sharedLibrary
set theIps to getAttributeListFromSublist(people, "theIp") of sharedLibrary
set mergedList to {}
repeat with i from 1 to count of theNames -- Assuming both lists have identical length
	copy item i of theNames & " (" & item i of theIps & ")" to the end of mergedList
end repeat

(* Selecting the person to support *)
choose from list theNames with title "Available persons"
if result is not false then
	(* Retrieve IP corresponding to the chosen name *)
	set selectedItem to first item of result
	set the listPosition to getValuePositionInList(theNames, selectedItem) of sharedLibrary
	set chosenIp to item listPosition of theIps
	
	(* Make it so *)
	try
		tell application "Screen Sharing"
			activate -- Bring app to the front
			GetURL "vnc://" & chosenIp
		end tell
	on error m number n
		beep
		display dialog m with title n buttons {"OK"} default button "OK" with icon stop
	end try
end if

-- EOF