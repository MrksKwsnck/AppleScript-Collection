(* Iterate though contacts in “Address Book” and perform tasks.
Author:	Markus Kwaśnicki
Date:	2011-12-27 *)

set sharedLibrary to load script file ((path to scripts folder as text) & "eu.kwasniccy.applescript.default.scptd:") -- Load common library

(* Checking phone numbers in Address Book for the correct format and cleaning them up if needed. *)
tell application "Contacts"
	set unwantedCharacters to {space, "-", "/"}
	
	repeat with eachPhoneNumber in (phones of people)
		set the currentPhoneNumber to value of eachPhoneNumber
		
		if the currentPhoneNumber is not equal to missing value then
			set cleanedPhoneNumber to currentPhoneNumber
			
			repeat with eachUnwantedCharacter in unwantedCharacters
				set cleanedPhoneNumber to textReplace(eachUnwantedCharacter, "", cleanedPhoneNumber) of sharedLibrary
			end repeat
			
			set value of eachPhoneNumber to cleanedPhoneNumber
			
			if the currentPhoneNumber begins with "0" then
				(* Without country prefix or non plus sign *)
			end if
		end if
	end repeat
	
	save -- Save done work
end tell

tell application "Contacts"
	set textItemDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ", " -- Defining the text item delimiter for coercing list items into text
	repeat with currentPerson in people
		set currentGroups to group of currentPerson -- List of groups curent person is assigned to
		set lengthOfCurrentGroups to length of currentGroups
		
		if lengthOfCurrentGroups = 0 then
			-- Empty if person is not assigned to a group
			log {(first name of currentPerson as text) & space & (last name of currentPerson as text), (organization of currentPerson as text)}
		else if lengthOfCurrentGroups > 1 then
			-- Person is assigned to more then one group
			log {(first name of currentPerson as text) & space & (last name of currentPerson as text), (organization of currentPerson as text)}
			log (name of groups of currentPerson) as text
		else
			-- Person is assigned to exact one group
		end if
	end repeat
	set AppleScript's text item delimiters to textItemDelimiters -- Setting text item delimiters to default value
end tell

