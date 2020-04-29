#!/bin/bash

#Extracts the public key from an SSL certificate in PEM format provided as an argument
#and generates a SHA256 digest of it and ultimately base64 encodes it

#This is useful in android public key pinning or pinning bypass

if [ $# -lt 1 ]; then
    echo "Usage: ./gensha256b64publickey.sh cert.cer (PEM format)"
else
    openssl x509 -in $1 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
fi
