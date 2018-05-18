# Bash

### Description
the purpose of the script is create an user and/or a policy and attach to the created user on the AWS platform.


### Requirements
AWS account
AWScli

### Paramerters

example:
```
./script.sh --username charles --policy my-policy --policy-file ../templates/policy.json --attach
```
Above command will create one user, one policy and will attach to the created user

### Arguments
 --username: <name to use>
 --policy: <name of the policy>
 --policy-file: <location of the json file containing a valid policy>
 --attach: <flag>

