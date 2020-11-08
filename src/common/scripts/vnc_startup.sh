#!/bin/bash
### every exit != 0 fails the script
set -e

## print out help
help (){
echo "
USAGE: /opt/vnc_startup.sh VNC_PORT:5901 VNC_PW:Passw0rd NO_VNC_PORT:6901

VNC_PORT is must have.
VNC_PW is needed when you first time to run a vnc or you want to overwrite the previous settting. 
NO_VNC_PORT only needed when you need use novnc.
"
}
if [[ $1 =~ -h|--help ]]; then
    help
    exit 0
fi

## resolve_vnc_connection
VNC_IP=$(hostname)

VNC_PORT=
VNC_PW=
NO_VNC_PORT=
for i in $*;do
    str1=`echo $i | cut -d':' -f1`
    str2=`echo $i | cut -d':' -f2`
    if [ $str1 == 'VNC_PORT' ];then
        VNC_PORT=$str2
    elif [ $str1 == 'VNC_PW' ];then
        VNC_PW=$str2
    elif [ $str1 == 'NO_VNC_PORT' ];then
        NO_VNC_PORT=$str2
    fi
done
echo "VNC_PORT:$VNC_PORT "
echo "VNC_PW:*** "
echo "NO_VNC_PORT:$NO_VNC_PORT "

VNC_ROOT=$HOME/vnc
mkdir -p "$VNC_ROOT"
LOG_FILE_DIR=$VNC_ROOT/vnc_logs
mkdir -p "$LOG_FILE_DIR"
LOG_FILE_PREFIX=$(date +%s)

if [ ! -d $HOME/.config/xfce4 ];then
    echo "first time to use vnc, copy vnc scripts files to home"
    \cp -r $DEFAULTHOME/.config $HOME
    \cp -r $DEFAULTHOME/Desktop $HOME
    \cp -r $DEFAULTHOME/noVNC $VNC_ROOT
    ln -s $VNC_ROOT/noVNC/vnc_lite.html $VNC_ROOT/noVNC/index.html
else
    echo "the vnc scripts files are already existing"
fi

## change vnc password
mkdir -p "$HOME/.vnc"
PASSWD_PATH="$HOME/.vnc/passwd"
if [ $VNC_PW ]; then
    echo -e "\n------------------ change VNC password  ------------------"
    if [ -f $PASSWD_PATH ]; then
        echo -e "\n---------  purging existing VNC password settings  ---------"
        rm -f $PASSWD_PATH
    fi
    echo "$VNC_PW" | vncpasswd -f >> $PASSWD_PATH
    chmod 600 $PASSWD_PATH
else
    if [ -f $PASSWD_PATH ]; then
        echo "you will use the VNC_PW which is set previously"
    else
        echo "you must set VNC_PW since there is no existing"
        exit 0
    fi
fi

if [ $VNC_PORT ]; then
    DISPLAY=:`expr $VNC_PORT - 5900`
    export DISPLAY
    echo -e "\n------------------ start VNC server ------------------------"
    echo "remove old vnc locks to be a reattachable container"
    vncserver -kill $DISPLAY &> $LOG_FILE_DIR/${LOG_FILE_PREFIX}_vnc_startup.log || echo "no locks present"

    echo -e "start vncserver with param: VNC_COL_DEPTH=$VNC_COL_DEPTH, VNC_RESOLUTION=$VNC_RESOLUTION\n..."
    vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION &> $LOG_FILE_DIR/${LOG_FILE_PREFIX}_vnc_startup.log
    
    echo -e "start window manager\n..."
    /opt/wm_startup.sh &> $LOG_FILE_DIR/${LOG_FILE_PREFIX}_wm_startup.log

    echo -e "\nVNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"
else
   echo "you must set VNC_PORT, and it should be more than 5900"
   exit 0
fi


## start vncserver and noVNC webclient
if [ $NO_VNC_PORT ]; then
    echo -e "\n------------------ start noVNC  ----------------------------"
    $VNC_ROOT/noVNC/utils/launch.sh --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT &> $LOG_FILE_DIR/${LOG_FILE_PREFIX}_no_vnc_startup.log & 
    echo -e "\nnoVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"
fi

while true
do
   sleep 1000
done
