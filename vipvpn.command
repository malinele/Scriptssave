#!/usr/bin/expect
spawn /opt/cisco/vpn/bin/vpn connect gate.vipmobile.rs/fix
expect "Username:"
send "nmitrovic\r"
expect "Password:"
send "V14tu3lT3@m2011\r"
expect eof
