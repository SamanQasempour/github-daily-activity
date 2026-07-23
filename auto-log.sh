#!/bin/bash

cd ~/github-daily-activity || exit

echo "Activity: $(date)" >> activity.log

git add .

git commit -m "Daily Activity $(date '+%Y-%m-%d %H:%M:%S')"

git push origin main

