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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "copying Mongo Repo"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "Installing MongoDB server"

systemctl enable mongod &>> $LOGS_FILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>> $LOGS_FILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "Restarted MongoDB"