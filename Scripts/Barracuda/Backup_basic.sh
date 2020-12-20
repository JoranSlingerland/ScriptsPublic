#!/bin/bash

 

##########################

# ftp server credentials #

##########################

HOST='192.168.0.16'

USER='USERNAME'

PW='PASSWORD'

 

FILENAME=box_`date +%e_%b_%Y__%H\UHR%M`.par

 

LOGFILE=/tmp/Par_FTPbackup.log

 

# Functions

gen_event() {

        /etc/phion/bin/events --type_id="131" --type_name="Logfile FTP backup" --layer_id="1" --layer_name="box" --class_id="1" --class_name="Storage" --data="Logfile FTP backup unsuccessful"

}

 

ftp_conn () {

        local i=$*

         # Call 1. Uses the ftp command with the -in switches.  -i turns off interactive prompting. -n Restrains FTP from attempting the auto-login feature.

        /usr/bin/ftp -in $i > /tmp/ftp.worked 2> /tmp/ftp.failed <<-EOF

        # Call 2. Here the login credentials are supplied by calling the variables.

        quote USER $USER

        quote PASS $PW

        # Call 3. Upload the file

        lcd /tmp

        cd /home/uploaddirectory/parfiles

        binary

        put $FILENAME

        # Call 4. Get the file for verification

        get $FILENAME retrieval.$$

        bye

EOF

 

        EXITSTATUS=$?

 

        # checks wether the ftp command returned 0 and if the file that was uploaded can be downloaded succesfuly (then we are safe that the file has been transfered!)

        if [ $EXITSTATUS != "0" ]

        then

                gen_event

            echo "****************************************" >> ${LOGFILE}

        echo "FTP transfer failed" >> ${LOGFILE}

    elif [ ! -f retrieval.$$ ]

        then

                gen_event

        else

                return

        fi

}

 

cleanup() {

       #rm -f /tmp/${FILENAME}

       rm -f /tmp/retrieval.*

       rm -f /tmp/ftp.worked

       rm -f /tmp/ftp.failed

}

 

echo "****************************************" >> ${LOGFILE}

date >> ${LOGFILE}

echo "Creating Par backup" >> ${LOGFILE}

 

# par file creation

cd /opt/phion/config/configroot/

sleep 5

/opt/phion/bin/phionar cdl /tmp/${FILENAME} *

sleep 10

 

echo "****************************************" >> ${LOGFILE}

echo "Trigger FTP Connection" >> ${LOGFILE}

 

# Actually triggers the backup

ftp_conn $HOST

 

echo "****************************************" >> ${LOGFILE}

echo "Garbage Collection" >> ${LOGFILE}

 

# Garbage Collection

cleanup

 

echo "****************************************" >> ${LOGFILE}

echo "Backup Completed on `date +%Y\ %m\ %d\ %T`">> ${LOGFILE}

echo "****************************************" >> ${LOGFILE}

exit 0;