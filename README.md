## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

(Images/Network-Diagram-Week-13.png)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the playbook file may be used to install only certain pieces of it, such as Filebeat.

Playbook 1: pentest.yml
```
---
- name: Config Web VM with Docker
  hosts: webservers
  become: true
  tasks:
  - name: docker.io
    apt:
      force_apt_get: yes
      update_cache: yes
      name: docker.io
      state: present

  - name: Install pip3
    apt:
      force_apt_get: yes
      name: python3-pip
      state: present

  - name: Install Docker python module
    pip:
      name: docker
      state: present

  - name: download and launch a docker web container
    docker_container:
      name: dvwa
      image: cyberxsecurity/dvwa
      state: started
      published_ports: 80:80

  - name: Enable docker service
    systemd:
      name: docker
      enabled: yes
```

Playbook 2: elksetup.yml
```
---
- name: Configure Elk VM with Docker
  hosts: elkservers
  remote_user: sysadmin
  become: true
  tasks:
    # Use apt module
    - name: Install docker.io
      apt:
        update_cache: yes
        force_apt_get: yes
        name: docker.io
        state: present
    
    # Use apt module
    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present
      
    # Use pip module (It will default to pip3)
    - name: Install Docker module
      pip:
        name: docker
        state: present
    
    # Use command module
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144
      
    # Use sysctl module
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: 262144
        state: present
        reload: yes
      
    # Use docker_container module
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
        # Please list the ports that ELK runs on
        published_ports:
          -  5601:5601
          -  9200:9200
          -  5044:5044


```
Playbook 3: filebeatinstall.yml
```
---
- name: installing and launching filebeat
  hosts: webservers
  become: yes
  tasks:
  
  - name: download filebeat deb
    command: curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb
 
  - name: install filebeat deb
    command: dpkg -i filebeat-7.4.0-amd64.deb
  
  - name: drop in filebeat.yml
    copy:
      src: /etc/ansible/filebeat-config.yml
      dest: /etc/filebeat/filebeat.yml
  
  - name: enable and configure system module
    command: filebeat modules enable system
  
  - name: setup filebeat
    command: filebeat setup
  
  - name: Start filebeat service
    command: service filebeat start
```

This document contains the following details:
- Description of the Topologu
- Access Policies
- ELK Configuration
  - Beats in Use
  - Machines Being Monitored
- How to Use the Ansible Build


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available, in addition to restricting access to the network.

Question: What aspect of security do load balancers protect? What is the advantage of a jump box?_
- Load balancers ensures security by providing availablity of the application. Load balancers take incoming client request and distribute it among a number of servers so that if one server is down, another can still serve client requests. 

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the configuration and system files.

Question: What does Filebeat watch for?
  - It watches monitor log files
Question: What does Metricbeat record?
  - It records system-level CPU, memory, file system, disk IO, and network IO statistics. Essentially, it monitors for every process running on an operating system 

The configuration details of each machine may be found below.

| Name     | Function | IP Address | Operating System |
|----------|----------|------------|------------------|
| Jump Box | Gateway  | 10.0.0.4   | Linux            |
| WEB-1    | DVWA     | 10.0.0.9   | Linux            |
| WEB-2.1  | DVWA     | 10.0.0.8   | Linux            |
| ELK      | ELK      | 10.1.0.4   | Linux            |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jumpbox machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- 40.69.99.134

Machines within the network can only be accessed by Jumpbox.
- Access from Jumpbox to Elk-server was allowed via SSH. Its internal IP is 10.0.0.4

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses |
|----------|---------------------|----------------------|
| Jump Box | SSH                 | 40.69.99.134         |
| WEB-1    | NO                  | 10.0.09              |
| WEB-2.1  | NO                  | 10.0.08              |
| ELK      | YES                 | 13.78.222.56         |



### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because...
Question: What is the main advantage of automating configuration with Ansible?
- You have full control of making any changes including duplicating VMs. This is prone to making less mistakes 
and allows consistency, speed and accuracy

The playbook implements the following tasks:
Question: In 3-5 bullets, explain the steps of the ELK installation play. E.g., install Docker; download image; etc.
- SSH into Jumpbox and start/attach Ansible docker container
- Created ELK playbook that had installation of Docker, Python, Docker's Python Module
- In order for smooth installation, increasing virtual memeory was required to support the stack so this was also added in the playbook
- Ran the playbook which downloaded the approperiate softwares
- SSH into ELK-SERVER to verify installation was completle and running


The following screenshot displays the result of running `docker ps` after successfully configuring the ELK instance.

(Images/docker-ps-elk.png)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
Question: List the IP addresses of the machines you are monitoring
- WEB-1: 10.0.0.9
- WEB-2.1: 10.0.0.8

We have installed the following Beats on these machines:
Question: Specify which Beats you successfully installed
- Filebeat

These Beats allow us to collect the following information from each machine:
Question: In 1-2 sentences, explain what kind of data each beat collects, and provide 1 example of what you expect to see. E.g., `Winlogbeat` collects Windows logs, which we use to track user logon events, etc.
- Filebeat allows us to collects logs from Virtual Machines that have the filebeat installed and sends the information to the ELK

### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned: 

SSH into the control node and follow the steps below:
- Copy the playbook file to Docker Container that has Ansible intalled.
- Update the /etc/ansible/hosts file to include elk servers
- Update /etc/ansible/files/filebeat-config.yml
```
output.elasticsearch:
hosts: ["10.1.0.4:9200"]
username: "elastic"

setup.kibana:
host: "10.1.0.4:5601"

```
- Update the Ansible configuration file /etc/ansible/ansible.cfg and set 'remote_user' parameter to admin user of the web servers


- Run the playbook, and navigate toto check that the installation worked as expected.

_TODO: Answer the following questions to fill in the blanks:_
Question: Which file is the playbook? Where do you copy it?
- filebeatinstall.yml is the file, /etc/ansible
Question: Which file do you update to make Ansible run the playbook on a specific machine? How do I specify which machine to install the ELK server on versus which to install Filebeat on?
- 
```
[webservers]
10.0.0.8 ansible_python_interpreter=/usr/bin/python3
10.0.0.9 ansible_python_interpreter=/usr/bin/python3

[elkservers]
10.1.0.4 ansible_python_interpreter=/usr/bin/python3
```


Question: Which URL do you navigate to in order to check that the ELK server is running?
http://13.78.222.56:5601/app/kibana#/
