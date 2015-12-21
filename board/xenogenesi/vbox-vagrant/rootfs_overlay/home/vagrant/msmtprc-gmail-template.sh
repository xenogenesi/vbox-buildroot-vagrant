#!/bin/sh

UNAME=${1:-USERNAME}
PASSW=${2:-PASSWORD}

cat <<EOF
defaults
tls on
tls_starttls on
tls_certcheck off
 
account default
host smtp.gmail.com
port 587
auth on
user ${UNAME}@gmail.com
password ${PASSW}
from ${UNAME}@gmail.com
logfile /usr/htdocs/logs/msmtp.log
EOF

printf "\n\n## copy or redirect the output to /usr/htdocs/msmtprc\n\n"

