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
 
# Advanced options
alldomains="enable"               # 'enable' or 'disable' automatic multi-domain authentication
localhome="enable"               # 'enable' or 'disable' force home directory to local drive
protocol="smb"                    # 'afp' or 'smb' change how home is mounted from server
mobile="disable"               # 'enable' or 'disable' mobile account support for offline logon
mobileconfirm="disable"          # 'enable' or 'disable' warn the user that a mobile acct will be created
useuncpath="disable"               # 'enable' or 'disable' use AD SMBHome attribute to determine the home dir
#UID="bu-ph-index-id-numeric"
user_shell="/bin/bash"          # e.g., /bin/bash or "none"
preferred="-nopreferred"     # Use the specified server for all Directory lookups and authentication
# (e.g. "-nopreferred" or "-preferred ad.server.edu")
admingroups="AD\celop_adms, AD\celop_senior_admissions_coordinator"     # These comma-separated AD groups may administer the machine (e.g. "" or "APPLE\mac admins")
 
# Login hook setting -- specify the path to a login hook that you want to run instead of this script
### End of configuration
 
# Activate the AD plugin
defaults write /Library/Preferences/DirectoryService/DirectoryService "Active Directory" "Active"
plutil -convert xml1 /Library/Preferences/DirectoryService/DirectoryService.plist
sleep 5
 
# Bind to AD
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
 
# Add the AD node to the search path
if [ "$alldomains" = "enable" ]; then
csp="/Active Directory/All Domains"
else
csp="/Active Directory/$domain"
fi
 
#dscl /Search -create / SearchPolicy CSPSearchPath
#dscl /Search -append / CSPSearchPath "/Active Directory/All Domains"
#dscl /Search/Contacts -create / SearchPolicy CSPSearchPath
#dscl /Search/Contacts -append / CSPSearchPath "/Active Directory/All Domains"
 
# This works in a pinch if the above code does not
defaults write /Library/Preferences/DirectoryService/SearchNodeConfig "Search Node Custom Path Array" -array "/Active Directory/All Domains"
defaults write /Library/Preferences/DirectoryService/SearchNodeConfig "Search Policy" -int 3
defaults write /Library/Preferences/DirectoryService/ContactsNodeConfig "Search Node Custom Path Array" -array "/Active Directory/All Domains"
defaults write /Library/Preferences/DirectoryService/ContactsNodeConfig "Search Policy" -int 3
 
plutil -convert xml1 /Library/Preferences/DirectoryService/SearchNodeConfig.plist