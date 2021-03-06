(* Author: Markus Kwaśnicki
Date: 2012-08-29
Description: Get the encoded file path of selected Finder objects as URL and copy it to the clipboard. *)

property domain : "eu.kwasniccy.applescript.service.finder.dateipfad-kopieren"
property theTitle : "Dateipfad kopieren"

on run {input, parameters}
	try
		set sharedLibrary to load script file ((path to scripts folder from user domain as text) & "eu.kwasniccy.applescript.default.scptd") as alias -- Include shared library
		
		if (count of input) > 1 then
			set itemList to {}
			repeat with currentItem in input
				set encodedFilePath to encodeFilePath(currentItem) of me
				copy encodedFilePath to the end of itemList
			end repeat
			
			choose from list itemList with title theTitle with prompt "In die Zwischenablage kopieren?" OK button name "Kopieren" cancel button name "Abbrechen"
			set theResult to result
			if theResult is not equal to false then
				set message to first item of theResult
				write2log(domain, message) of sharedLibrary
				set the clipboard to message
			end if
		else
			set message to encodeFilePath(first item of input) of me
			write2log(domain, message) of sharedLibrary
			
			tell application "Finder"
				display dialog "In die Zwischenablage kopieren?" with title theTitle default answer message buttons {"Abbrechen", "Kopieren"} default button "Kopieren" cancel button "Abbrechen" with icon note
				if button returned of result is equal to "Kopieren" then
					set the clipboard to message
				end if
			end tell
		end if
	on error m number n
		if n is not equal to -128 then
			set message to m & " (" & n & ")"
			write2log(domain, message) of sharedLibrary
			tell application "Finder" to display dialog message with title theTitle buttons ("OK") default button "OK" with icon stop
		end if
	end try
	
	return input
	
end run

on encodeFilePath(filePath)
	set sharedLibrary to load script file ((path to scripts folder from user domain as text) & "eu.kwasniccy.applescript.default.scptd") as alias -- Include shared library
	
	set tmp to filePath as alias
	set tmp to urlencode(POSIX path of tmp) of sharedLibrary
	(* Correcting some encoded characters *)
	set tmp to textReplace("%80", "Ä", tmp) of sharedLibrary
	set tmp to textReplace("%8A", "ä", tmp) of sharedLibrary
	set tmp to textReplace("%85", "Ö", tmp) of sharedLibrary
	set tmp to textReplace("%9A", "ö", tmp) of sharedLibrary
	set tmp to textReplace("%86", "Ü", tmp) of sharedLibrary
	set tmp to textReplace("%9F", "ü", tmp) of sharedLibrary
	set tmp to textReplace("%A7", "ß", tmp) of sharedLibrary
	set tmp to textReplace("+", "%20", tmp) of sharedLibrary
	set tmp to textReplace("%2F", "/", tmp) of sharedLibrary
	-- End
	set tmp to "file://" & tmp
	return tmp
end encodeFilePath