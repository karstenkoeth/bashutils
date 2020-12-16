#!/bin/bash

scp -i ~/.ssh/AppSpaceLab.pem  ubuntu@ec2-54-93-113-44.eu-central-1.compute.amazonaws.com:/home/ubuntu/"$1" "$2"
