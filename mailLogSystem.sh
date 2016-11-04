
#!/bin/bash

# The script is called on every modified line 
# so we have to exsecute the only last one 
echo -n "$$" > /tmp/watch-myprocess.pid
sleep 5
pidAllowed=`cat /tmp/watch-myprocess.pid`
if [[ $$ -ne $pidAllowed ]]
then
    exit 0
fi


# Log file to read and time-stamps definition
file="/var/log/apache2/error.log"
today10min=`oldLANG=$LANG;LANG=en_EN.UTF-8;date --date='10 minutes ago' '+%a %b %d %H:%M';LANG=$oldLANG`
todayhour=`oldLANG=$LANG;LANG=en_EN.UTF-8;date '+%a %b %d %H:%M';LANG=$oldLANG`
today=`oldLANG=$LANG;LANG=en_EN.UTF-8;date '+%a %b %d';LANG=$oldLANG`

# Define some mail parameters 
mailTo="dev@obiba.org"
mailSubject="Server Maelstrom Error"

mailMessage="

The service on www.maelstrom-research.org is down, please check 

Ps :
It may send other warning errors, please ignore if problem solved

Errors loged in  $file :

"


# String to find on the log file
errorToFind[1]="PHP Parse error:"
errorToFind[2]="PHP Fatal error:"
#errorToFind[3]="ap_proxy_connect_backend disabling worker for \(localhost\)"
#errorToFind[4]="proxy: HTTP: disabled connection for \(localhost\)"

sendMail=0 # Initialize to omit sending mail if not necessary
while read line ; do
for (( index=1; index<=${#errorToFind[@]} ; index++))
do
if [[  $line > $today10min && $line < $todayhour ]]
then

if [[ $line =~ $today.*${errorToFind[$index]} ]]
then
mailMessage="$mailMessage$line
"
sendMail=$sendMail"1"
echo "$todayhour :: Error send to mail $mailTo";
fi

fi
done
done < $file


# Send Mail if key word found on log fils
if [[ $sendMail -ne 0 ]]
then
echo "$mailMessage" | mail -s "$mailSubject" $mailTo
fi

# Else  only to log (*/5 * * * * /toPath/mailLogSystem.sh > /var/log/mail_error/sent_mail_error.log 2>&1)
if [[ $sendMail == 0 ]]
then
echo "$todayhour ::  No errors";
fi

