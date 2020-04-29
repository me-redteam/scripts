#!/bin/bash

if [ $# -lt 1 ]; then
    echo "Usage: ./gensha256b64publickey.sh cert.cer (PEM format)"
else
    openssl x509 -in $1 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
fi
