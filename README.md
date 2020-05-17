# Singularity VNC Container

This singularity vnc container is originally from the [Consol Docker container](https://github.com/ConSol/docker-headless-vnc-container) , and change it so that it can be used in multi-tenant HPC  and AI environment.



The container image is installed with the following components:

* Desktop environment [**Xfce4**](http://www.xfce.org) 
* VNC-Server 
* [**noVNC**](https://github.com/novnc/noVNC) - HTML5 VNC client 
* Browsers:
  * Mozilla Firefox
  

## Usage
- git clone this project

- build container

  ```
  cd singularityvnc
  singularity build centosvnc.simg  centos-xfce-vnc.sif
  ```

- singularity shell to check the help

  ```
  singularity shell centosvnc.simg 
  Singularity centosvnc.simg:~> cd /opt
  Singularity centosvnc.simg:/opt> ./vnc_startup.sh -h
  
  USAGE: ./vnc_startup.sh VNC_PORT:5901 VNC_PW:Passw0rd NO_VNC_PORT:6901
  
  VNC_PORT is must have.
  VNC_PW is needed when you first time to run a vnc or you want to overwrite the previous settting.
  NO_VNC_PORT should be provided when you need use novnc.
  
  ```

- launch VNC

      Singularity centosvnc.simg:/opt> ./vnc_startup.sh VNC_PORT:5901 VNC_PW:Passw0rd
      VNC_PORT 5901
      VNC_PW ***
      NO_VNC_PORT
      the vnc scripts files are already existing
      
      ------------------ change VNC password  ------------------
      
      ---------  purging existing VNC password settings  ---------
      
      ------------------ start VNC server ------------------------
      remove old vnc locks to be a reattachable container
      start vncserver with param: VNC_COL_DEPTH=24, VNC_RESOLUTION=1280x1024
      ...
      start window manager
      ...
      
      VNCSERVER started on DISPLAY= :1
              => connect via VNC viewer with 10.240.208.106:5901

* access through vncviewer

  ![VNC Desktop access via VNC Viewer](./vnc.png)

  Note: If you want to **access the vnc through web browser**,  when you run ./vnc_startup.sh, you should provide the **NO_VNC_PORT:6901**.
