write a shell script for ansible installation.

1. check ansible installed or not.
  if installed show the ansible version 
2. if not istalled install with below instructions
      sudo apt update -y
      sudo apt install -y software-properties-common
      sudo add-apt-repository --yes --update ppa:ansible/ansible
      sudo apt install -y ansible
3. show the ansible verion
     ansible --version

4. my concept is with the ansible. i am not using it for control manchine and node machine. 
installed ansible tool and  in the same server localhost is act as a node server. 
for this configuration. 
        Generate SSH keys. 
       add pub key(id_ed25519.pub) into /home/ubuntu/.ssh/authorized_keys
       check it loggin into localhost (ssh ubuntu@localhost)
       add localhost (localhost) inot /etc/ansible/hosts file
       cehck with ansible its working or not (ansible -m ping all)

       