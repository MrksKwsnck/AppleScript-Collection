(* Droplet to resize images considering the proportion. 
by Markus Kwaśnicki
2012-01-19 *)

on open (itemList)
	(* Determine maximal dimension of the first image in the list *)
	tell application "Image Events"
		set theImage to open (first item of itemList) as alias
		
		set width to item 1 of (dimensions of theImage as list)
		set height to item 2 of (dimensions of theImage as list)
		set currentSize to missing value
		if width > height then -- Landscape orientation
			set currentSize to width
			log "Landscape"
		else -- Portrait orientation
			set currentSize to height
			log "Portrait"
		end if
		
		close theImage
	end tell
	(* Determined currentSize of the first image in the list *)
	
	display dialog "Enter new maximal size (width/height) in pixels as integer:" with title "Resize to size" default answer currentSize
	set newMaxSize to text returned of result
	newMaxSize as integer
	
	repeat with theItem in itemList
		-- Make it so!
		tell application "Finder"
			set imageAlias to (theItem as alias)
			set imageDuplicate to (duplicate imageAlias) as alias
			
			tell application "Image Events"
				set theImage to open imageDuplicate
				scale theImage to size newMaxSize
				save theImage
				close theImage
			end tell
		end tell
		-- End of proseccing current item
	end repeat
	
	beep -- All images processed
end open