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
    echo -e "$2 ... $R failure $N" | tee -a $LOGS_FILE
    exit 1
else
    echo -e "$2 ... $G success $N" | tee -a $LOGS_FILE
fi

}

dnf module disable nodejs -y &>> $LOGS_FILE
VALIDATE $? "Disabling NodeJS Default version"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
VALIDATE $? "Enabling NodeJS 20 version"

dnf install nodejs -y &>> $LOGS_FILE
VALIDATE $? "Installing NodeJS 20 version"

id roboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "roboshop user already exist ... $Y SKIPPING $N"
fi    

mkdir -p /app
VALIDATE $? "Creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
VALIDATE $? "Downloading catalogue zip file"

cd /app
VALIDATE $? "Moving to app directory"

unzip /tmp/catalogue.zip $&>> $LOGS_FILE
VALIDATE $? "Unzip catalogue code"

npm install &>> $LOGS_FILE
VALIDATE $? "Installing nodejs dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue $&>> $LOGS_FILE
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

