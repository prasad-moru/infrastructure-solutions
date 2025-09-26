
Create New Ubuntu Server 

clone repository ` git pull https://github.com/prasad-moru/infrastructure-solutions.git `

Configure Ansible setup ` cd /infrastructure-solutions/`
  Run Script   `./ansible_inst-ubuntu.sh` After Ansible configuration 
Completed
Go To  `cd infrastructure-solutions/jenkins_Ansible_role`

Run Ansible Role `ansible-role -i inventory.ini playbook.yml `
