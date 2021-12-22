#!/usr/bin/env python3

import socket
import time

srv_ip = {'drive.google.com':'', 'mail.google.com':'', 'google.com':''}
print("Start cheking IPs ...")
while(1==1):
    for srv in srv_ip.keys():
        ip = socket.gethostbyname(srv)
        if(ip == srv_ip[srv]):
            print(f'{srv} - {ip}')
        elif(srv_ip[srv]==''):
            srv_ip[srv] = ip
        else:
            print(f'[ERROR] {srv} IP mismatch: {srv_ip[srv]} {ip}')
            srv_ip[srv] = ip
    time.sleep(10)
