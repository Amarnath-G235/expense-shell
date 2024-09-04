#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log

mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
       echo "Please run this script with root previleges" | tee -a $LOG_FILE
       exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then 
       echo " $2 is failed.." | tee -a $LOG_FILE
       exit 1
    else
       echo "$2 is success.." | tee -a $LOG_FILE
    fi
}

CHECK_ROOT

echo "script started executing at : $(date)" | tee -a $LOG_FILE

dnf list installed mysql
if [ $? -ne 0 ]
then
    echo "mysql is not installed..going to install it" | tee -a $LOG_FILE
    dnf install mysql-server -y &>>$LOG_FILE
    VALIDATE $? "Installing mysql server"
else 
    echo "mysql is already installed.." | tee -a $LOG_FILE
fi

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysql server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "mysql starting"

mysql -h mysql.ukom81s.online -u root -pExpenseApp@1 -e "show databases;" &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo " mysql server root password not set up..setting now " &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "Setting root password for mysql server"
else
    echo -e "Mysql root password already set up..$Y Skipping $N" | tee -a $LOG_FILE
fi
