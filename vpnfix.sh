#!/bin/sh
sudo killall -INT -u root vpnagentd
sudo SystemStarter start vpnagentd
