(* Description:	A set of handlers to share with all scripts.
Dependencies:
• http://www.latenightsw.com/freeware/RecordTools/index.html
Author: Markus Kwaśnicki
Date: 2011-11-30 *)

(* 
@description Returns the path to the property list file located in the appropriate preferences folder in Mac format as text. 
@param Text The file name of the property list file.
@return Text The absolute path to the property list file.
*)
on getPathToPropertyListFile(plist)
	set preferencesFolder to path to preferences
	set propertyListFile to (preferencesFolder as text) & plist & ".plist"
	return propertyListFile
end getPathToPropertyListFile

(* 
@description Create the property list file inside the preferences folder without default values if not exists already. 
@param Text The absolute path to the property list file.
*)
on createPlist(plist)
	set PropertyListXML to "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>username</key><string></string><key>password</key><string></string></dict></plist>"
	set pathToPlist to getPathToPropertyListFile(plist)
	
	set propertyListFileHandler to open for access pathToPlist with write permission
	write PropertyListXML to propertyListFileHandler
	close access propertyListFileHandler
end createPlist

(* 
@description Return an alias to the property list file which is located in the appropriate preferences folder. 
@param Text The file name to the property list file.
@return Alias The alias to the property list file.
*)
on getOrCreatePlist(plist)
	try
		(* Retrieving full path to the property list needed *)
		set propertyListFile to getPathToPropertyListFile(plist)
		set propertyListFile to propertyListFile as alias
		(* end *)
	on error m number n
		if n is equal to -43 then
			createPlist(plist)
		else
			error m number n
		end if
	end try
	
	return propertyListFile
end getOrCreatePlist

(*
@description Return a value from a plist.
@param Alias thePlist The plist handle.
@param Text theKey The key of the plist.
@return Text theValue The value to the given key of the plist.
*)
on getProperty(thePlist, theKey)
	set plistHandle to POSIX path of thePlist
	tell application "System Events"
		tell property list file plistHandle -- Works with posix path of type „Text“ only
			tell contents
				return value of property list item theKey
			end tell
		end tell
	end tell
end getProperty

(*
@description Set a value to a plist.
@param Alias thePlist The plist handle.
@param Text theKey The key of the plist.
@param Text theValue The value to the given key of the plist.
*)
on setProperty(thePlist, theKey, theValue)
	set plistHandle to POSIX path of thePlist
	tell application "System Events"
		tell property list file plistHandle -- Works with posix path of type „Text“ only
			tell contents
				set value of property list item theKey to theValue
			end tell
		end tell
	end tell
end setProperty

(*
@description
@param Text searchTerm The search term to replace.
@param Text replacement The replacement for replacing with.
@param Text theText The text being substituted.
@return Text Returns the text with replaced parts.
*)
on textReplace(searchTerm, replacement, theText)
	considering case
		set previousTextItemDelimiters to AppleScript's text item delimiters
		set AppleScript's text item delimiters to searchTerm
		set textItems to text items of theText
		set AppleScript's text item delimiters to replacement
		set returnValue to textItems as text
		set AppleScript's text item delimiters to previousTextItemDelimiters
	end considering
	return returnValue
end textReplace

(* 
@description Converting given date to ISO 8601 timestamp 
@param Date A date object or missing value for now.
@return Text The fully qualified ISO 8601 timestamp.
*)
on dateToIso8601(now)
	if now is equal to missing value then
		set now to current date
	end if
	
	set timestamp_delimiter to "T"
	set date_delimiter to "-"
	set time_delimiter to ":"
	
	-- Date
	set year_string to year of now as string
	set month_string to month of now as integer as string
	if length of month_string is 1 then
		set month_string to "0" & month_string
	end if
	set day_string to day of now as string
	if length of day_string is 1 then
		set day_string to "0" & day_string
	end if
	
	-- Time
	set hours_string to hours of now as string
	if length of hours_string is 1 then
		set hours_string to "0" & hours_string
	end if
	set minutes_string to minutes of now as string
	if length of minutes_string is 1 then
		set minutes_string to "0" & minutes_string
	end if
	set seconds_string to seconds of now as string
	if length of seconds_string is 1 then
		set seconds_string to "0" & seconds_string
	end if
	
	-- Time zone
	set time_zone_difference to (time to GMT) / 3600 -- Real number of hours
	if time_zone_difference is greater than 0 then
		set time_zone_prefix to "+"
	else
		set time_zone_prefix to "-"
	end if
	set time_zone_hours to (round time_zone_difference rounding down) as integer -- "as integer" rounds upwards
	if time_zone_hours is less than 0 then
		set time_zone_hours to (-1 * time_zone_hours)
	end if
	set time_zone_hours to time_zone_hours as string
	if length of time_zone_hours is 1 then
		set time_zone_hours to "0" & time_zone_hours
	end if
	set time_zone_minutes to (60 * (time_zone_difference mod 1)) as integer as string
	if length of time_zone_minutes is 1 then
		set time_zone_minutes to "0" & time_zone_minutes
	end if
	
	return year_string & date_delimiter & month_string & date_delimiter & day_string & timestamp_delimiter & hours_string & time_delimiter & minutes_string & time_delimiter & seconds_string & time_zone_prefix & time_zone_hours & time_delimiter & time_zone_minutes
end dateToIso8601

(*
@description Write a message to a log file.
@param Text The domain of the aplication.
@param Text The message to log.
*)
on write2log(domain, message)
	set the error_log to ((path to library folder from user domain as text) & "Logs:") & domain & ".log"
	try
		open for access file the error_log with write permission
		write (dateToIso8601(missing value) & tab & message & return) to file the error_log starting at eof
		close access file the error_log
	on error
		try
			close access file the error_log
		end try
	end try
end write2log

(* 
@description The Folder Action Script needs to be present in one of the appropriate folders.
@param Alias TargetFolder
@param Text scriptFileName
*)
on attachScriptToFolder(TargetFolder, scriptFileName)
	tell application "Finder" to set FAName to displayed name of TargetFolder
	tell application "System Events"
		if folder action FAName exists then
			-- Don´t make a new one
		else
			make new folder action at end of folder actions with properties {path:TargetFolder} -- name:FAName, 
		end if
		
		tell folder action FAName
			if script scriptFileName exists then
				-- Don´t make a new one
			else
				make new script at end of scripts with properties {name:scriptFileName}
			end if
		end tell
		
		set folder actions enabled to true -- Enable Folder Actions
	end tell
end attachScriptToFolder

(* i was looking for a quick and dirty way to encode some data to pass to a url via POST or GET with applescript and Internet Explorer, 
there were a few OSAXen which have that ability, but i didn't feel like installing anything, 
so i wrote this thing (works with standard ascii characters, characters above ascii 127 may run into character set issues see: applescript for converting macroman to windows-1252 encoding) 
Credits: http://harvey.nu/applescript_url_encode_routine.html *)
on urlencode(theText)
	set theTextEnc to ""
	repeat with eachChar in characters of theText
		set useChar to eachChar
		set eachCharNum to ASCII number of eachChar
		if eachCharNum = 32 then
			set useChar to "+"
		else if (eachCharNum ≠ 42) and (eachCharNum ≠ 95) and (eachCharNum < 45 or eachCharNum > 46) and (eachCharNum < 48 or eachCharNum > 57) and (eachCharNum < 65 or eachCharNum > 90) and (eachCharNum < 97 or eachCharNum > 122) then
			set firstDig to round (eachCharNum / 16) rounding down
			set secondDig to eachCharNum mod 16
			if firstDig > 9 then
				set aNum to firstDig + 55
				set firstDig to ASCII character aNum
			end if
			if secondDig > 9 then
				set aNum to secondDig + 55
				set secondDig to ASCII character aNum
			end if
			set numHex to ("%" & (firstDig as string) & (secondDig as string)) as string
			set useChar to numHex
		end if
		set theTextEnc to theTextEnc & useChar as string
	end repeat
	return theTextEnc
end urlencode

(* A reader named Eric was inspired to send in the following url decoder. 
It seems to work, at least with ascii characters up to 127 (which is probably sufficient for many applications). 
For some higher number characters (like characters with umlauts, symbols etc) you may run into character encoding problems since the mac uses the mac roman character set, 
and most servers on the net use something like the windows latin set for encoding. (e.g. ü might decode as ¸) see: convert macroman to windows-1252 encoding 
Credits: http://harvey.nu/applescript_url_decode_routine.html *)
on urldecode(theText)
	set sDst to ""
	set sHex to "0123456789ABCDEF"
	set i to 1
	repeat while i ≤ length of theText
		set c to character i of theText
		if c = "+" then
			set sDst to sDst & " "
		else if c = "%" then
			if i > ((length of theText) - 2) then
				display dialog ("Invalid URL Encoded string - missing hex char") buttons {"Crap..."} with icon stop
				return ""
			end if
			set iCVal1 to (offset of (character (i + 1) of theText) in sHex) - 1
			set iCVal2 to (offset of (character (i + 2) of theText) in sHex) - 1
			if iCVal1 = -1 or iCVal2 = -1 then
				display dialog ("Invalid URL Encoded string - not 2 hex chars after % sign") buttons {"Crap..."} with icon stop
				return ""
			end if
			set sDst to sDst & (ASCII character (iCVal1 * 16 + iCVal2))
			set i to i + 2
		else
			set sDst to sDst & c
		end if
		set i to i + 1
	end repeat
	return sDst
end urldecode

(* Return a list with values of given attribute in sublist *)
on getAttributeListFromSublist(theList, theAttribute)
	set newList to {}
	repeat with listItem in theList
		copy («event ScTlrcGt» theAttribute given «class XMlO»:listItem) to the end of newList
	end repeat
	return newList
end getAttributeListFromSublist

(* Return the position within a list of the first occurrence of a given value *)
on getValuePositionInList(theList, theValue)
	repeat with i from 1 to count of theList
		if item i of theList is equal to theValue then
			return i
		end if
	end repeat
	return -1
end getValuePositionInList

(* End of Library *)

