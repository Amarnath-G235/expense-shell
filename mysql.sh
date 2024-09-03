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

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing mySQL server"

systemctl enable mysqld  &>> $LOG_FILE
VALIDATE $? "Enabling mySQL"

systemctl start mysqld  &>> $LOG_FILE
VALIDATE $? "Starting of mySQL sever"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>> $LOG_FILE
VALIDATE $? "Set up of root password for mySQL"
