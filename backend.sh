#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1) # $0--> will gives us script name.
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

USERID=$(id -u)
CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then 
       echo -e"$R please run this script with sudo previleges $N" | tee -a &>>$LOG_FILE
       exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
      echo -e " $2 is $R failed.. $N" | tee -a $LOG_FILE
      exit 1
    else
      echo -e " $2 is $G success. $N"  | tee -a $LOG_FILE
    fi
}

echo "script started executing at :$(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf module disable nodejs -y
VALIDATE $? "Disabling default nodejs" &>>LOG_FILE

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling nodejs20" &>>LOG_FILE

dnf install nodejs -y
VALIDATE $? "Installing nodejs" &>>LOG_FILE

useradd expense
VALIDATE $? "Creating expense user"