#!/usr/bin/env python3

import os
print ("Start searching for changed files ...")
bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
pwd = os.getcwd()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd + "/" + prepare_result)
        is_change = True
if is_change == False:
    print ("Modifieded files not found.")
