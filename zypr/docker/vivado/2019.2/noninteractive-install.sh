#!/usr/bin/env expect
set timeout -1
set user [lindex $argv 0]
set password [lindex $argv 1]

spawn ./Xil_installer/xsetup -b AuthTokenGen
expect "User ID:"
send "${user}\r"
expect "Password:"
send "${password}\r"
expect "*Saved authentication token file successfully*"
send_user "install auth token generated\r"

spawn ./Xil_installer/xsetup -a XilinxEULA,3rdPartyEULA,WebTalkTerms -b Install -c config.txt
expect "*Installation completed successfully.*"
sleep 12
exit