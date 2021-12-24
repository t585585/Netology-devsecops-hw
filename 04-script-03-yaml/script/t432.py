#!/usr/bin/env python3

import socket
import time
import json
import yaml

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
    with open("432.json", 'w') as json_file:
        json_file.write(json.dumps(srv_ip))
    with open("432.yml", 'w') as yaml_file:
        yaml_file.write(yaml.dump(srv_ip))
    time.sleep(10)
