(*
Author:		Markus Kwaśnicki
Date:		2011-07-25
Version:		6
Description:	This Service invokes a call to a text selected telephone number using the provided DTStAG call manager API. The configuration for each subscriber is readen from the property list file. Developed on Mac OS X 10.6 (Snow Leopard), runs with Lion, too.
*)

-- BEGIN of Properties
property domain : "eu.kwasniccy.dtstag.nummer-waehlen"
property ownSubscribersNumber : missing value (* In the format of PREFIX-NUMBER-DIRECT_DIAL *)
property ownPIN : missing value (* The PIN to the own number *)
-- END of Properties

on run {input, parameters}
	(* Your script goes here *)
	
	set loadedLibrary to load script file ((path to scripts folder from user domain as text) & "eu.kwasniccy.applescript.default.scptd") as alias -- Include all handlers
	
	try
		set propertyList to getOrCreatePlist(domain) of loadedLibrary
		
		set ownSubscribersNumber to getProperty(propertyList, "username") of loadedLibrary
		if ownSubscribersNumber is equal to "" then
			using terms from application "Finder"
				display dialog "Geben Sie bitte Ihre qualifizierte Rufnummer ein:" default answer "0611-949104-XX" buttons {"Abbrechen", "OK"} default button "OK" cancel button "Abbrechen" with title "Authentifizierung erforderlich" with icon note
				set ownSubscribersNumber to text returned of result
			end using terms from
			setProperty(propertyList, "username", ownSubscribersNumber) of loadedLibrary
		end if
		write2log(domain, "Subscribers number: " & ownSubscribersNumber) of loadedLibrary
		
		set ownPIN to getProperty(propertyList, "password") of loadedLibrary
		if ownPIN is equal to "" then
			using terms from application "Finder"
				display dialog "Geben Sie bitte Ihre PIN ein:" default answer "0000" buttons {"Abbrechen", "OK"} default button "OK" cancel button "Abbrechen" with title "Authentifizierung erforderlich" with icon note with hidden answer
				set ownPIN to text returned of result
			end using terms from
			setProperty(propertyList, "password", ownPIN) of loadedLibrary
		end if
		write2log(domain, "PIN: " & ownPIN) of loadedLibrary
		
		set numberToCall to (extractNumberToCall from input as string)
		write2log(domain, "Number to call: " & numberToCall) of loadedLibrary -- Log number to call here
		call given number:numberToCall
	on error m number n
		write2log(domain, n & ": " & m) of loadedLibrary
		using terms from application "Finder"
			display dialog m buttons {"OK"} default button "OK" with title n with icon stop
		end using terms from
	end try
	
	return input
end run

-- BEGIN of Subroutines
on extractNumberToCall from input
	set extractedNumberToCall to ""
	set allowedCharacters to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
	repeat with i from 1 to length of input
		set currentCharacter to (character i of input)
		if currentCharacter is equal to "+" then
			set currentCharacter to "00"
		else if currentCharacter is in allowedCharacters then
			(* Do nothing here *)
		else
			set currentCharacter to ""
		end if
		set extractedNumberToCall to extractedNumberToCall & currentCharacter
	end repeat
	
	set returnValue to missing value
	if extractedNumberToCall is not equal to "" then
		set returnValue to "0" & extractedNumberToCall
	else
		set returnValue to ""
	end if
	return returnValue
end extractNumberToCall

on call given number:toCall
	set uri to "https://power.dtst.de/callmanager.php?"
	set uri to uri & "userlogin=" & ownSubscribersNumber
	set uri to uri & "&userpin=" & ownPIN
	set uri to uri & "&to=" & toCall
	try
		set command to "/usr/bin/curl --insecure '" & uri & "'"
		--display dialog "Command line" default answer command
		do shell script command
		if result contains "Invalid value" then
			set answer to "Ungültige Nummer wurde gewählt: " & toCall
			display alert answer as critical
		end if
	on error m number n
		error m number n
	end try
end call
-- END of Subroutines

(* End of AppleScript *)
