#!/bin/bash

ssh -i ~/.ssh/AppSpaceLab.pem  ubuntu@ec2-XX-XX-XX-XX.eu-central-1.compute.amazonaws.com

# Use ~/.ssh/config instead of this file. E.g. with this content:
#
# Host appspacelab
#        Hostname ec2-XX-XX-XX-XX.eu-central-1.compute.amazonaws.com
#        User ubuntu
#        IdentityFile ~/.ssh/AppSpaceLab.pem
#
#
# With such a config file connect to the server with:
# > ssh appspacelab
#
