#!/bin/bash


USERID=$(id -u)
LOGS_FOLDER="/var/logs/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"

if [ $USERID -ne 0 ]; then
    echo -e " $R Please run this script as root or with sudo privileges. $N" | tee -a $LOGS_FILE
    exit 1
fi

#create logs folder if not exists
mkdir -p $LOGS_FOLDER

VALIDATE () {
if [ $1 -ne 0 ]; then
    echo -e "Installing $2 is $R failure $N" | tee -a $LOGS_FILE
    exit 1
else
    echo -e "Installing $2 is $G successful $N" | tee -a $LOGS_FILE
fi

}

dnf module disable redis -y &>> $LOGS_FILE
dnf module enable redis:7 -y &>> $LOGS_FILE
VALIDATE $? "Enabling Redis 7"

dnf install redis -y &>> $LOGS_FILE
VALIDATE $? "Installed Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>> $LOGS_FILE
VALIDATE $? "Allowing remote connections"

systemctl enable redis &>> $LOGS_FILE
systemctl start redis 
VALIDATE $? "Enabled and Started Redis"