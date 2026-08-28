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

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling NodeJS 20 version"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing NodeJS 20 version"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
VALIDATE $? "Creating roboshop system user"

mkdir /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATE $? "Downloading catalogue zip file"