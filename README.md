# urlopen.sh

Opens a Windows `.URL` file or a Linux/BSD `.desktop` file in a currently running webbrowser, or if none running, in a new browser.

Basically, it searches for the first line containing `URL=`, gets the part after the equal sign which should be the hyperlink, and opens it. I use `xdg-open` as a last resort.
