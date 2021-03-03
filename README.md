# bashutils

This repository contains some very small bash scripts helping me to have nearly same environment on all machines. Maybe, some scripts are also useful for other persons. Therefore, the repository is public.

Check out with:
git clone https://github.com/karstenkoeth/bashutils.git

# REST API Server in bash

## Content

The server consists of two files:

- http-echo.sh
- http-text.sh

## Install

Install all files as normal user with:

`./install_bashutils_local.sh`

## Run

The server could be started with http-echo.sh:

`http-echo.sh -p 3007 &`

In this example, the server listens on tcp port 3007. For every connection to this port, a new process of http-text.sh will be started.
The server is something like a cloud clipboard. With the command "addDoubleHead", a new clibboard instance will be created.
Connect to the server e.g. with curl:

`curl http://127.0.0.1:3007/api/addDoubleHead`

The server will answer with a JSON structure, e.g.:

`{ "DoubleHead": "C58A2027-094E-4FDE-A460-F9BBFB564257" }`

With this secret, data could be send to the server or received from the server.

There is no limit for the number of different clipboards used at the same time.

There is no limit regarding the number of users using the clipboard at the same time.

### Send Data

With http PUT, the data is send into the clipboard. Use e.g. curl to send a JSON structure to the clipboard:

`curl -X PUT -H "Content-Type: application/json" http://127.0.0.1:3007/data/C58A2027-094E-4FDE-A460-F9BBFB564257/ -d '{"key1":"value"}'`

You can also send complex data, e.g. a complete web side:

`curl -X PUT -H "Content-Type: application/text" http://127.0.0.1:3007/data/C58A2027-094E-4FDE-A460-F9BBFB564257/ -d "<html><head><title>My Cloud Clipboard</title></head><body><h1>Important</h1><p>Go!</p></body></html>"`

Or put a single number to the clipboard:

`curl -X PUT -H "Content-Type: application/text" http://127.0.0.1:3007/data/C58A2027-094E-4FDE-A460-F9BBFB564257/ -d "123"`

### Receive Data

With the secret from the command "addDoubleHead", using curl to receive data:

`curl http://127.0.0.1:3007/data/C58A2027-094E-4FDE-A460-F9BBFB564257/`

With a browser, put in the following line as URL to get data:

`http://127.0.0.1:3007/data/C58A2027-094E-4FDE-A460-F9BBFB564257/`

With SICK Dashboard Builder (https:/sd3.cloud.sick.com), set following lines in configuration - REST Binding:

`URL: http://127.0.0.1:3007/data/C58A2027-094E-4FDE-A460-F9BBFB564257/`

`Path:`

`Interval: 500 ms`

`Post processor function:`

Play a little bit around with the Interval setting to reach the optimum for your system.

There is no other shield to protect the data. All persons knowing the unique uuid can access the data.

## Prototype

This server is in prototype state. Therefore, all data and all created clipboards could be lost, if the main server process (http-echo.sh) is killed. 

## Help

Get all program parameters with:

`http-echo.sh -h`

# MQTT 2 REST Server

This server accepts MQTT messages and offers these over REST-API.
Under the hood, mosquitto CLI and the REST API Server is used.

## Content

The server consists of these files:

- mqtt2rest.sh
- mqtt2file.sh
- http-echo.sh
- http-text.sh

## Install

Install all files as normal user with:

`./install_bashutils_local.sh`

## Run

The server could be started with:

`mqtt2rest.sh &`

## Connect to Server

MQTT2REST works under mqtt topic *prototype* on port *1883*. The REST API is reachable under port *11883*.

# Connect to Servers

These scripts (ssh2*, scp2*, scpF*) are only useful in combination with the private keys. Therefore, as an alien user of this repository they are useless.
