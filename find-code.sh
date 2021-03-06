#!/bin/bash
# 	find-code.sh  3.206.494  2019-02-20T15:41:14.388035-06:00 (CST)  https://github.com/BradleyA/markit.git  uadmin  six-rpi3b.cptx86.com 3.205-6-gc359d9f  
# 	   change find so one line for each local repository is printed 
# 	find-code.sh  3.154.314  2019-01-21T10:35:35.944657-06:00 (CST)  https://github.com/BradleyA/markit  uadmin  six-rpi3b.cptx86.com 3.153  
# 	   production standard 5 include Copyright notice 
# 	find-code.sh  3.152.312  2019-01-19T23:26:41.498938-06:00 (CST)  https://github.com/BradleyA/markit.git  uadmin  six-rpi3b.cptx86.com 3.151  
# 	   production standard 4 update display_help LANGUAGE close #58 
# 	find-code.sh  3.145.301  2018-11-16T23:24:34.883320-06:00 (CST)  https://github.com/BradleyA/markit  uadmin  one-rpi3b.cptx86.com 3.144  
# 	   find-code.sh run shellcheck to clean up future minor incidents close #57 
# 	find-code.sh  3.144.300  2018-11-16T23:16:34.591093-06:00 (CST)  https://github.com/BradleyA/markit  uadmin  one-rpi3b.cptx86.com 3.143  
# 	   find-code.sh change log format and order close #56 
# 	find-code.sh  3.143.299  2018-11-16T23:03:01.457123-06:00 (CST)  https://github.com/BradleyA/markit  uadmin  one-rpi3b.cptx86.com 3.142  
# 	   find-code.sh Order of precedence: add support for environment variable (export DEBUG=1), default code close #55
# 	find-code.sh  3.129.285  2018-10-31T21:19:55.719763-05:00 (CDT)  https://github.com/BradleyA/markit  uadmin  six-rpi3b.cptx86.com 3.128  
# 	   find-code.sh support environment variables close #44 
#
### find-code.sh - Search systems from clones from repositories
#       Copyright (c) 2019 Bradley Allen
#       License is in the online DOCUMENTATION, DOCUMENTATION URL defined below.
###
#   production standard 5
#       Order of precedence: environment variable, default code
if [ "${DEBUG}" == "" ] ; then DEBUG="0" ; fi   # 0 = debug off, 1 = debug on, 'export DEBUG=1', 'unset DEBUG' to unset environment variable (bash)
#	set -x
#	set -v
BOLD=$(tput -Txterm bold)
NORMAL=$(tput -Txterm sgr0)
###
display_help() {
echo -e "\n${NORMAL}${0} - Search systems for .git repositories"
echo -e "\nUSAGE\n   ${0}  [<CLUSTER>] [<DATA_DIR>] [SYSTEMS_FILE]"
echo    "   ${0} [--help | -help | help | -h | h | -?]"
echo    "   ${0} [--version | -version | -v]"
echo -e "\nDESCRIPTION"
#       Displaying help DESCRIPTION in English en_US.UTF-8
echo    "This script searches each system found in SYSTEMS file for .git repositories"
echo    "in ~/.. directories."
echo -e "\nThis script reads /usr/local/data/us-tx-cluster-1/SYSTEMS file for hosts."
echo    "The hosts are one FQDN or IP address per line for all hosts in a cluster."
echo    "Lines in SYSTEMS file that begin with a # are comments.  The SYSTEMS file is"
echo    "used by Linux-admin/cluster-command/cluster-command.sh, markit/find-code.sh,"
echo    "pi-display/create-message/create-display-message.sh, and other scripts.  A"
echo    "different SYSTEMS file can be entered on the command line or environment"
echo    "variable."
echo -e "\nTo avoid many login prompts for each host in a cluster, enter the following:"
echo    "${BOLD}ssh-copy-id uadmin@<host-name>${NORMAL} to each host in the SYSTEMS file."
#       Displaying help DESCRIPTION in French fr_CA.UTF-8, fr_FR.UTF-8, fr_CH.UTF-8
if [ "${LANG}" == "fr_CA.UTF-8" ] || [ "${LANG}" == "fr_FR.UTF-8" ] || [ "${LANG}" == "fr_CH.UTF-8" ] ; then
        echo -e "\n--> ${LANG}"
        echo    "<votre aide va ici>" # your help goes here
        echo    "Souhaitez-vous traduire la section description?" # Do you want to translate the description section?
elif ! [ "${LANG}" == "en_US.UTF-8" ] ; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Your language, ${LANG}, is not supported.  Would you like to translate the description section?" 1>&2
fi
echo -e "\nEnvironment Variables"
echo    "If using the bash shell, enter; export CLUSTER='us-west1' on the command"
echo    "line to set the CLUSTER environment variable to 'us-west1'.  Use the command,"
echo    "unset CLUSTER to remove the exported information from the CLUSTER environment"
echo    "variable.  To set an environment variable to be defined at login, add it to"
echo    "~/.bashrc file or you can modify this script with your default location for"
echo    "CLUSTER, DATA_DIR, MESSAGE_FILE, and SYSTEMS_FILE.  You are on your own"
echo    "defining environment variables if you are using other shells."
echo    "   CLUSTER       (default us-tx-cluster-1/)"
echo    "   DATA_DIR      (default /usr/local/data/)"
echo    "   SYSTEMS_FILE  (default SYSTEMS)"
echo    "   DEBUG         (default '0')"
echo -e "\nOPTIONS"
echo    "   CLUSTER       name of cluster directory (default us-tx-cluster-1)"
echo    "   DATA_DIR      path to cluster data directory (default /usr/local/data/)"
echo    "   SYSTEMS_FILE  name of SYSTEMS file (default SYSTEMS)"
echo -e "\nDOCUMENTATION\nhttps://github.com/BradleyA/markit"
echo -e "\nEXAMPLES\n   ${0}\n\n   Search systems for .git repositories using defaults\n"
}

#       Date and time function ISO 8601
get_date_stamp() {
DATE_STAMP=$(date +%Y-%m-%dT%H:%M:%S.%6N%:z)
TEMP=$(date +%Z)
DATE_STAMP="${DATE_STAMP} (${TEMP})"
}

#       Fully qualified domain name FQDN hostname
LOCALHOST=$(hostname -f)

#       Version
SCRIPT_NAME=$(head -2 "${0}" | awk {'printf $2'})
SCRIPT_VERSION=$(head -2 "${0}" | awk {'printf $3'})

#       UID and GID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

#       Default help and version arguments
if [ "$1" == "--help" ] || [ "$1" == "-help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "h" ] || [ "$1" == "-?" ] ; then
        display_help | more
        exit 0
fi
if [ "$1" == "--version" ] || [ "$1" == "-version" ] || [ "$1" == "version" ] || [ "$1" == "-v" ] ; then
        echo "${SCRIPT_NAME} ${SCRIPT_VERSION}"
        exit 0
fi

#       INFO
get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[INFO]${NORMAL}  Started..." 1>&2

#       DEBUG
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Name_of_command >${0}< Name_of_arg1 >${1}< Name_of_arg2 >${2}< Name_of_arg3 >${3}<  Version of bash ${BASH_VERSION}" 1>&2 ; fi

#       Order of precedence: CLI argument, environment variable, default code
if [ $# -ge  1 ]  ; then CLUSTER=${1} ; elif [ "${CLUSTER}" == "" ] ; then CLUSTER="us-tx-cluster-1/" ; fi
#       order of precedence: CLI argument, environment variable, default code
if [ $# -ge  3 ]  ; then DATA_DIR=${2} ; elif [ "${DATA_DIR}" == "" ] ; then DATA_DIR="/usr/local/data/" ; fi
#       order of precedence: CLI argument, environment variable, default code
if [ $# -ge  5 ]  ; then SYSTEMS_FILE=${3} ; elif [ "${SYSTEMS_FILE}" == "" ] ; then SYSTEMS_FILE="SYSTEMS" ; fi
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  CLUSTER >${CLUSTER}< DATA_DIR >${DATA_DIR}< SYSTEMS_FILE >${SYSTEMS_FILE}< PATH >${PATH}<" 1>&2 ; fi

###
#	REMOTECOMMAND="find /home/uadmin -type d \( -name 'git*' -o -name 'bitbucket' \)  -print"
#	REMOTECOMMAND="find ~/.. 2>/dev/null -type d -execdir test -d '.git' \; -print -prune"
REMOTECOMMAND="find ~/.. 2>/dev/null -type d -name '.git' -print"

#       Check if ${SYSTEMS_FILE} file is on system, one FQDN or IP address per line for all hosts in cluster
if ! [ -e ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE} ] || ! [ -s ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE} ] ; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  ${SYSTEMS_FILE} file missing or empty, creating ${SYSTEMS_FILE} file with local host.  Edit ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE} file and add additional hosts that are in the cluster." 1>&2


        echo -e "###     List of hosts used by cluster-command.sh & create-message.sh"  > ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE}
        echo -e "#       One FQDN or IP address per line for all hosts in cluster" > ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE}
        echo -e "###" > ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE}
        echo    "${LOCALHOST}" > ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE}
fi

#	Loop through hosts in ${SYSTEMS_FILE} file
REMOTEHOST=$(grep -v "#" ${DATA_DIR}/${CLUSTER}/${SYSTEMS_FILE})
for NODE in ${REMOTEHOST} ; do
        echo -e "\n${BOLD}  -->  ${NODE}${NORMAL}       ->${REMOTECOMMAND}<-" 
        if [ "${LOCALHOST}" != "${NODE}" ] ; then
                ssh -t "${USER}"@"${NODE}" "${REMOTECOMMAND}"
        else
                eval "${REMOTECOMMAND}"
        fi
done

#
get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[INFO]${NORMAL}  Operation finished." 1>&2
###
