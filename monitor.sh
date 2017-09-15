#!/bin/sh
# Bash script that will exit with code 0 if SironAML scoring was a success, and 1 if it was a failure
#
# Usage
#
#    echo "55 15 * * 1-5 /bin/sh /home/sakiki/monitor.sh /home/sakiki/runScoring.log && curl -fsS --retry 3 https://hchk.io/1803ec50-91b7-4333-b4ee-70b5457c0f6e > /dev/null" > /var/cron/tabs/sakiki
#    scp monitor.sh sakiki@amlprod.ffai.local:/home/sakiki

#----------------------------

NLINES=10

function waitFor {
  # Monitoring a file until a string is found
  # https://superuser.com/a/548193/642842
  match=$1
  fifo=/tmp/tmpfifo.$$
  mkfifo "${fifo}" || exit 1
  tail -n $NLINES -f $TARGET >${fifo} &
  tailpid=$! # optional
  timeout 5m grep -m 1 "$match" "${fifo}" # <<<< timeout after 5 minutes if no result
  kill "${tailpid}" # optional
  rm "${fifo}"
  if [ $? -ne 0 ]; then
    echo "waiting for '" $match "' timed out"
    exit 2
  fi
}

TARGET=$1
echo "Watching $TARGET"

# push new empty lines to avoid false positive
seq 1 $NLINES >> $TARGET

echo "step 1: wait for start of scoring"
waitFor "S i r o n  A M L"

echo "step 2: wait for success or error"
# How do I grep for multiple patterns?
# https://unix.stackexchange.com/a/37316
waitFor "F i n i s h e d    s u c c e s s f u l l y\|E R R O R    d u r i n g    p r o c e s s i n g" $TARGET

echo "now determine which of successful or error happened"
tail -n $NLINES $TARGET | grep -m 1 "F i n i s h e d    s u c c e s s f u l l y"
if [ $? -eq 0 ]; then
  echo "was a success! :)"
  exit 0
fi

echo "was a failure :("
exit 1
