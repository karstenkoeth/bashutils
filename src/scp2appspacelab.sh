#!/bin/bash

scp -i ~/.ssh/AppSpaceLab.pem "$1" ubuntu@ec2-54-93-113-44.eu-central-1.compute.amazonaws.com:/home/ubuntu/"$2"
