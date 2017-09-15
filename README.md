# sironaml-healthchecks-notifier
Script that monitors the SironAML log file for "sucess" and pings healthchecks.io

Since all I had from SironAML was a log file,
this project allowed me to ping [healthchecks.io](https://healthchecks.io/) upon successful scoring,
and thus email me when the scoring failed for whichever reason

# Usage
1. Install cygwin on siron server with: cron curl
2. Follow instructions [here](http://www.davidjnice.com/cygwin_cron_service.html) to enable cron on cygwin. Excerpt below
3. Also install `sshd` to be able to ssh into server (will require a user for running the daemon, similar to the cron server user `cyg_runassrv`)

# cron job
1. Put `monitor.sh` in `/usr/bin`
2. Do a `chmod +x /usr/bin/monitor.sh`
3. Run `crontab -e`
4. add a job: `55 15 * * 1-5 timeout 600 monitor.sh /home/sakiki/runScoring.log && curl -fsS --retry 3 https://hchk.io/123-123-123 > /dev/null`

Remember that `runScoring.log` is the result log file from running a scoring

Note to self:
- from `ffa-mfe/r-ffa/aml/runScoring.sh`,
- which in its turn is launched by `ffa-mfe/r-ffa/aml/examples/cronJobScoring.R`

To view error logs, log in with Remote Desktop to windoze, Start / Event Viewer / Windows Logs / Application

# Excerpt from instructions for cygwin cron

```
Installing & Configuring the Cygwin Cron Service in Windows.

To set up cron on Cygwin, you'll need to install two additional cygwin packages using the cygwin setup.exe:

    cron: Vixie's Cron
    cygrunsrv: NT/W2K service initiator

Both programs are in the "Admin" category. Cron is the cron-daemon and Cygrunsrv is the program used to install & manage Cygwin programs as Windows services.

You'll also need vi(m) installed if you haven't already as it's the default editor for the crontab command. (It is possible to use another editor such as nano provided you set it as your default editor in your bash profile.)

Once you have the packages installed you can install cron as a Windows Service using Cygrunsrv.

cygrunsrv --install cron --path /usr/sbin/cron --args -n

There are a lot of web posts that say you should use cygrunsrv -I cron -p /usr/sbin/cron -a -D (See Errors #1 & #2).

By default, cron will install as a service that uses the Local System account. If you test cron at this point - for Windows 2003 at least - the windows event log will show Windows Application Event Log: (CRON) error (can't switch user context) - See error #3. This is because your test crontab is set up as the local administrator but the service is running as the 'Local System' account and does not have permission to create a token object.

To finish off the install, create a new user called cygrunsrv and use the Local Security Policy snap-in to allow that user to 'Create a token object', 'Logon as a service' & 'Replace a process level token' using the local group policy.

You will also need to add the user to the Local Administrators Group. I've added this as a note because I'm currently checking what permissions are really required. If it's possible, it would be better to not have this account added to the Local Administrators Group.

Set the service to run as .\cygrunsrv, set the password and restart the cron service.

You can start and stop the cron service by using:

    Using the Windows Services Snap-in
    From a cmd window or run dialogue; 'net start cron' & 'net stop cron'
    Or, since you are setting this up in Cygwin; 'cygrunsrv --start cron' & 'cygrunsrv --start cron'

To test the service, set up a crontab as the local administrator and check that it runs. A good test is to open a cygwin bash shell and run

$crontab -e

This will open the crontab in vi(m). Add the following line:

* * * * * echo "Cron test at $(date +\%k:\%M)" >> /cygdrive/c/crontest.txt 2>&1

(A little tip here; if you use the date command in a cron job, you need to escape the % characters will a backslash otherwise it won't work...)

If everything is running correctly this will generate a file called c:\crontest.log and add a new line every minute. 
```
