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
