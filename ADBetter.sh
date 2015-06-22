#!/bin/sh
 
computerid=`/usr/sbin/scutil --get LocalHostName`

# Standard parameters
domain="ad.bu.edu"               # fully qualified DNS name of Active Directory Domain
printf "Type Username of a privileged network user: "
read udn
#udn="diradmin"               # username of a privileged network user
printf "Type diradmin password: "
read -s password
#password="password"                         # password of a privileged network user
ou="CN=Computers,DC=domain,DC=school,DC=edu"          # Distinguished name of container for the computer


dsconfigad -f -a $computerid -domain $domain -u $udn -p "$password" -ou "$ou" -uid "bu-ph-index-id-numeric"

# Configure advanced AD plugin options
if [ "$admingroups" = "" ]; then
dsconfigad -nogroups
else
dsconfigad -groups "$admingroups"
fi
 
dsconfigad -alldomains $alldomains -localhome $localhome -protocol $protocol \
-mobile $mobile -mobileconfirm $mobileconfirm -useuncpath $useuncpath \
-shell $user_shell $preferred
 
# Restart DirectoryService (necessary to reload AD plugin activation settings)
killall DirectoryService