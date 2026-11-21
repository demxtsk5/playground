#!/bin/sh
osascript -e 'Tell application "System Events" to display dialog "Ansible benötigt Administrator-Rechte:" default answer "" with hidden answer' -e 'text returned of result' 2>/dev/null