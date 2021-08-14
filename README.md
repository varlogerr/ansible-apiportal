## Requirements

### Target machines

* version 8.* of CentOS / Alma Linux / Rocky Linux
* ssh server running (`sudo dnf install -y openssh-server && sudo systemctl enable --now sshd`)
* python3 (`dnf install python3`)
* create sudo user (optional, if you want to offload ansible tasks to a system user):

  ```bash
  # create a control user, for example "ansible"
  sudo useradd -rms /bin/bash ansible
  # make control user sudoer
  sudo usermod -aG wheel ansible
  # give him a password
  sudo passwd ansible
  ```

### Ansible control machine

* ansible ([installation instructions][ansible installation])
* (optional) if you plan to use `gen-vars.sh` tool `python` or `python3` should be in the PATH
* (optional) if you plan to configure ansible to connect to target machines with username and password (not ssh keys), `sshpass` must be installed

## Usage

**Note**: all the code snippets and instructions below are meant for UNIX-like OSes. In case you use something else translate them to your OS commands

Login to your ansible control machine.

1) Clone the repo:

    ```bash
    # replace <ansible-apiportal repo url> with the actual
    # repo url, clone the repo to some directory (for 
    # example portalbook) and cd to there
    git clone <ansible-apiportal repo url> portalbook
    cd portalbook
    ```

2) Initialize configuration directory with `init-conf.sh` script:

    ```bash
    # read init-conf.sh script help
    ./bin/init-conf.sh -h
    # initialize configuration directory with copying
    # API Portal installation package there
    ./bin/init-conf.sh ~/Downloads/apiporta-install.tgz
    ```

    Or manually:

    ```bash
    mkdir -p conf/{group_vars,host_vars,secrets}
    cp samples/inv.yml conf
    touch conf/group_vars/.gitignore
    touch conf/host_vars/.gitignore
    touch conf/secrets/.gitignore
    cp ~/Downloads/apiporta-install.tgz ./conf
    ```

3) Configure deployment inventory:

    ```bash
    # edit inventory file
    vim conf/inv.yml
    ```

4) Generate host vars file with `gen-vars.sh` script:

    ```bash
    # read gen-vars.sh script help
    ./bin/gen-vars.sh -h
    # generate vars file (given you ansible target
    # host name is "apiportal")
    ./bin/gen-vars.sh conf/host_vars/apiportal.yml
    ```

    Or manually:

    ```bash
    cp samples/vars.yml conf/host_vars/apiportal.yml
    ```

5) Configure installation settings:

    ```bash
    # edit variables file
    vim conf/host_vars/apiportal.yml
    ```

6) Run ansible playbook

    ```bash
    # run the playbook using the inventory file
    ansible-playbook -i conf/inv.yml apiportal.yml
    ```

[ansible installation]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
