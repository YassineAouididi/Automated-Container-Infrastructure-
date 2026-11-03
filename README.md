# Automated Container Infrastructure

An Infrastructure Automation project that deploys and manages containerized web services across multiple Linux virtual machines using **Ansible, Docker, and Nginx**.

The project demonstrates configuration management, container deployment, load balancing, and repeatable infrastructure automation in a VirtualBox home lab.

## Architecture

```text
                  Client / Browser
                         |
                         v
              Nginx Load Balancer
              Arch Linux Controller
                 127.0.0.1:8080
                         |
              +----------+----------+
              |                     |
              v                     v
       Ubuntu Server VM       Rocky Linux VM
       Apache Container       Apache Container
       Guest port 8080        Guest port 8080
              |                     |
       Host port 8081        Host port 8082
              +----------+----------+
                         |
                VirtualBox NAT
```

### Components

| Component | Role |
|---|---|
| Arch Linux | Ansible controller and Nginx load balancer |
| Ubuntu Server VM | Docker host and Apache backend |
| Rocky Linux VM | Docker host and Apache backend |
| Ansible | Configuration management and automation |
| Docker | Container runtime |
| Apache HTTP Server | Backend web service |
| Nginx | Reverse proxy and round-robin load balancer |
| VirtualBox | Virtual machine and NAT networking |

## Features

- Automated Docker installation on Ubuntu and Rocky Linux
- Apache container deployment using Ansible
- Custom HTML pages identifying each backend
- Ansible-managed Nginx configuration
- Round-robin traffic distribution between backend servers
- Reusable Ansible roles, templates, and handlers
- SSH-based remote management
- Repeatable deployment and configuration

## Project Structure

```text
automated-container-infrastructure/
└── ansible/
    ├── ansible.cfg
    ├── inventory/
    │   └── hosts.yml
    ├── playbooks/
    │   ├── install_docker.yml
    │   ├── deploy_apache.yml
    │   └── configure_load_balancer.yml
    └── roles/
        ├── apache_container/
        │   ├── defaults/
        │   │   └── main.yml
        │   └── tasks/
        │       └── main.yml
        └── nginx_load_balancer/
            ├── defaults/
            │   └── main.yml
            ├── handlers/
            │   └── main.yml
            ├── tasks/
            │   └── main.yml
            └── templates/
                └── nginx.conf.j2
```

## Prerequisites

- Arch Linux controller
- VirtualBox
- Ubuntu Server VM
- Rocky Linux VM
- Ansible installed on the controller
- SSH access to both VMs
- SSH key authentication configured
- Internet access on the VMs

Install Ansible on Arch Linux:

```bash
sudo pacman -S ansible
```

## VirtualBox Networking

The lab uses NAT port forwarding to access services hosted inside the VMs.

| VM | Host port | Guest port | Purpose |
|---|---:|---:|---|
| Ubuntu | 2222 | 22 | SSH |
| Ubuntu | 8081 | 8080 | Apache backend |
| Rocky Linux | 2223 | 22 | SSH |
| Rocky Linux | 8082 | 8080 | Apache backend |

The Nginx load balancer listens on the controller at port `8080`.

## Configuration

### 1. Clone the repository

```bash
git clone <YOUR_REPOSITORY_URL>
cd automated-container-infrastructure/ansible
```

### 2. Configure SSH access

Ensure your SSH key is available:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Test SSH connectivity:

```bash
ssh -p 2222 ubuntu@127.0.0.1
ssh -p 2223 root@127.0.0.1
```

### 3. Configure the Ansible inventory

Edit `inventory/hosts.yml` to match your VM connection details:

```yaml
all:
  children:
    linux_servers:
      hosts:
        ubuntu:
          ansible_host: 127.0.0.1
          ansible_port: 2222
          ansible_user: ubuntu
          ansible_python_interpreter: /usr/bin/python3.12

        rocky:
          ansible_host: 127.0.0.1
          ansible_port: 2223
          ansible_user: root
          ansible_python_interpreter: /usr/bin/python3.12
```

Update the Python interpreter path if your VMs use a different version.

### 4. Verify Ansible connectivity

```bash
ansible linux_servers -m ping
```

Expected result: both hosts return `"ping": "pong"`.

## Deployment

Run the playbooks from the `ansible/` directory.

### Install Docker

```bash
ansible-playbook playbooks/install_docker.yml --ask-become-pass
```

Enter the Ubuntu sudo password when prompted, if required.

### Deploy Apache containers

```bash
ansible-playbook playbooks/deploy_apache.yml --ask-become-pass
```

This deploys an Apache container on each VM and serves a page identifying the backend.

### Configure the Nginx load balancer

```bash
ansible-playbook playbooks/configure_load_balancer.yml --ask-become-pass
```

This installs Nginx on the controller, deploys its configuration from an Ansible template, validates the configuration, and enables the service.

## Verification

### Test each backend directly

```bash
curl http://127.0.0.1:8081
curl http://127.0.0.1:8082
```

Expected page identifiers:

- `Deployed by Ansible on ubuntu-vm`
- `Deployed by Ansible on rocky-vm`

### Test the load balancer

```bash
curl http://127.0.0.1:8080
```

Run multiple requests:

```bash
for i in {1..30}; do
  curl -s http://127.0.0.1:8080 | grep "Deployed by Ansible"
done
```

Expected result: requests are distributed between the Ubuntu and Rocky Linux backends. In the lab test, 30 requests returned 15 responses from each VM.

### Validate Nginx

```bash
sudo nginx -t
sudo systemctl status nginx --no-pager
```

## Troubleshooting

| Problem | Possible solution |
|---|---|
| Ansible cannot connect to a VM | Check VM state, SSH port forwarding, username, and SSH key |
| Permission denied during installation | Run the playbook with `--ask-become-pass` when sudo is required |
| Backend is unreachable | Check the Docker container and VirtualBox forwarding rules |
| Nginx configuration test fails | Review `roles/nginx_load_balancer/templates/nginx.conf.j2` |
| Nginx does not restart | Check `sudo journalctl -u nginx -e` |
| Ansible cannot find a role | Verify the project `ansible.cfg` and role directory paths |

## Skills Demonstrated

- Linux administration
- Ansible inventories, playbooks, roles, templates, and handlers
- Docker container deployment
- Nginx reverse proxy and load balancing
- VirtualBox networking and NAT port forwarding
- SSH administration
- Infrastructure automation and troubleshooting

## Future Improvements

- Add health checks and backend failure handling
- Add HTTPS with TLS certificates
- Add Prometheus and Grafana monitoring
- Add CI/CD using GitHub Actions
- Replace NAT port forwarding with a dedicated lab network
- Add automated tests and deployment verification

## Author

**Yassine Aouididi**  
Junior Cloud / DevOps Engineer

