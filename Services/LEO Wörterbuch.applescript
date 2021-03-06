(* Description: Open a default browsers window with the translation result page from „LEO Dictionary“ of the selected text. 
Author: Markus Kwaśnicki
Date: 2011-11-30 *)

property loadedLibrary : load script file ((path to scripts folder from user domain as text) & "eu.kwasniccy.applescript.default.scptd") as alias -- Include common handlers
property appDomain : "eu.kwasniccy.leo-dictionary"

on run {input, parameters}
	try
		set textSelection to first item of input
		set textToTranslate to missing value
		
		(* Trimming selection to maximum of 255 characters allowed *)
		if length of textSelection > 255 then
			set textToTranslate to text 1 through 255 of textSelection
		else
			set textToTranslate to textSelection
		end if
		
		(* URL encode the text to be translated before sending to the service *)
		set textToTranslate to urlencode(textToTranslate) of loadedLibrary
		
		write2log(appDomain, textToTranslate) of loadedLibrary
		open location "http://dict.leo.org/ende?search=" & textToTranslate
	on error m number n
		tell application "Finder"
			write2log(appDomain, n & ": " & m) of loadedLibrary
			display dialog m buttons {"OK"} default button "OK" with title n with icon 0
		end tell
	end try
	
	return input
end run
