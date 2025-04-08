#!/bin/bash

# Get the current timestamp
timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Get the list of logged in users and save to a file
who > /var/log/logged_users.log

# Append the timestamp and the list of logged users to the file
echo "$timestamp - Logged in users:" >> /var/log/logged_users.log
cat /var/log/logged_users.log >> /var/log/logged_users_with_timestamp.log
echo "----------------------------------------" >> /var/log/logged_users_with_timestamp.log
