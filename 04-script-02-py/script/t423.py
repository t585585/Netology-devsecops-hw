#!/usr/bin/env python3

import os
import sys

try:
    pwd = sys.argv[1]
except:
    sys.exit("\nUsage:\n   t423.py [path of repo]\n")

print ("Start searching for changed files ...")
bash_command = ["cd " + pwd, "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
pwd = os.popen(bash_command[0]+"&& pwd").read().rstrip()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd + "/" + prepare_result)
        is_change = True
if is_change == False:
    print ("Modifieded files not found.")
