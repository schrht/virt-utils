# Usage

1. Update yaml and credentials.  
   `vi resource_keeper.yaml`  
   `vi credentials`  
2. Create app image  
   `podman build -t resource_keeper .`  
3. Run app as contianer  
   `podman run -it --name resource_keeper --rm resource_keeper | tee -a resource_keeper.log`  
4. Run app with more debugging  
   `podman run -it --name resource_keeper resource_keeper /bin/bash`  
   `podman start resource_keeper`  
   `podman rm -f resource_keeper` 

# Autorun

1. Enable crond.service.  
   `sudo systemctl enable --now crond.service`  
2. Configure crontab.  
   `crontab -e`  
2. Paste the following lines.  
```
SHELL=/bin/bash
PATH=/usr/sbin:/usr/bin:/home/cheshi/bin

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * command to be executed

00 20 *  *  * podman run -it --name resource_keeper --rm resource_keeper 2>&1 | tee -a /tmp/resource_keeper.log
```

