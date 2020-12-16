#!/bin/bash

echo "[$PROG_NAME:STATUS] Starting ..."

# bash echo
#socat -T 1 -d -d TCP-L:10081,reuseaddr,fork,crlf SYSTEM:"echo -e \"\\\"HTTP/1.0 200 OK\\\nDocumentType: text/plain\\\n\\\ndate: \$\(date\)\\\nserver:\$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\n\\\"\"; cat; echo -e \"\\\"\\\n\\\"\""

# bsd echo, e.g. on MAC:
socat -T 1 -d -d TCP-L:10081,reuseaddr,fork,crlf SYSTEM:"echo \"\\\"HTTP/1.0 200 OK\\\nDocumentType: text/plain\\\n\\\ndate: \$\(date\)\\\nserver:\$SOCAT_SOCKADDR:\$SOCAT_SOCKPORT\\\nclient: \$SOCAT_PEERADDR:\$SOCAT_PEERPORT\\\n\\\"\"; cat; echo -e \"\\\"\\\n\\\"\""

echo "[$PROG_NAME:STATUS] Done."
