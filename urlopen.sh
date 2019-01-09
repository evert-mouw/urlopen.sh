#!/bin/bash

# ABOUT
# Opens a Windows .URL file or a Linux/BSD .desktop file
# in a currently running webbrowser, or if none running,
# in a new browser.

# BACKGROUND
# Basically, it searches for the first line containing 'URL=',
# gets the part after the equal sign which should be the
# hyperlink, and opens it. I use xdg-open as a last resort.

# AUTHOR
# Evert Mouw <post@evert.net>

# HISTORY
# 2019-01-06 first version
# 2019-01-07 fixes and additions
# 2019-01-09 better input cleaning

# Do we get a file?
if ! [[ -e "$1" ]]
then
	echo "Could not find a file."
	echo "Invoke like $0 /path/to/url/file"
	exit 1
fi

# Clean up (remove BASEURL and ORIGURL, convert to unix line endings)
CLEANED=$(cat "$1" | sed 's/\r//' | grep -vE '[BASE|ORIG]URL')

# Get the first url. The "URL=" must be at the beginning of the line.
URL=$(echo "$CLEANED" | grep '^URL=' | head -n 1)
URL=${URL:4}
if [[ $URL == "" ]]
then
	echo "No URL found in $1"
	exit 1
fi
echo "Opening $URL"

# Find browsers on the system; add browsers if you have other ones
# you might want to edit this to your preference ordening ;-)
# Shortening the list will speed up this script (a very little).
BROWSERS="chromium firefox brave midori konqueror opera palemoon seamonkey google-chrome vivaldi falkon qutebrowser min eolie epiphanie surf eric dillo netsurf elinks lynx links2 links w3m"
for BROWSER in $BROWSERS
do
	if command -v $BROWSER > /dev/null 2>&1
	then
		BROWSERLIST="$BROWSERLIST $BROWSER"
	fi
done
BROWSERLIST=${BROWSERLIST:1}
if [[ $BROWSERLIST == "" ]]
then
	echo "No browsers found ?!"
	echo "Pathetically trying xdg-open instead..."
	xdg-open "$URL"
	exit 1
fi
echo "Browsers found: $BROWSERLIST"

# Find out if there is a browser running already.
if ! command -v pidof
then
	echo "Sorry but I need the 'pidof' program."
	exit 1
fi
for BROWSER in $BROWSERLIST
do
	if pidof $BROWSER > /dev/null 2>&1
	then
		OPENBROWSERS="$OPENBROWSERS $BROWSER"
	fi
done
OPENBROWSERS=${OPENBROWSERS:1}
if [[ $OPENBROWSERS == "" ]]
then
	echo "No running browsers found."
else
	echo "Running browsers: $OPENBROWSERS"
fi

# NOTE: Yeah this could be done faster, just use the first running browser,
# but maybe later on I want to offer the user (myself) the option to
# choose from a list of running browsers or so...

# Open the URL in the first running browser, or
# if no browser is running, start a new browser.
for BROWSER in $OPENBROWSERS $BROWSERLIST
do
	$BROWSER "$URL" & disown
	echo "URL opened in $BROWSER"
	exit
done

# Is this script still running? Then we failed at starting a browser...
# Try this as a method of last resort:
echo "Failed to start a browser normally, reverting to xdg-open..."
xdg-open "$URL"
exit 1
