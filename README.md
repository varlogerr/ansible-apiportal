## Requirements

### Target machines

* version 8.* of CentOS / Alma Linux / Rocky Linux
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
* (optional) if you plan to use `gen-vars.sh` tool python or python3 should be in the PATH

## Usage

**Note**: all the code snippets and instructions below are meant for UNIX-like OSes. In case you use something else translate them to your OS commands

Login to your ansible control machine and follow the code snippets.

```bash
# replace <ansible-apiportal repo url> with the actual repo
# url, clone the repo to some directory (for example
# portalbook) and cd to there
git clone <ansible-apiportal repo url> portalbook
cd portalbook
# copy sample inventory file to `inv` directory file with
# some meaningful name (for example prod.yml) and fill the
# copy with your values
cp samples/inv.yml inv/prod.yml
vim inv/prod.yml # ... editing
```

Now it's time to configure your installation

```bash
# copy sample vars file to `host_vars` or `group_vars`
# directory file with your host or hosts group name taken
# from inventory file (for example for `apiportal` host) 
# and fill the copy with your values
cp samples/vars.yml host_vars/apiportal.yml
vim host_vars/apiportal.yml # ... editing
```

Or using gen vars helper script

```bash
# generate vars file and fill it with your values
./bin/gen-vars.sh -o host_vars/apiportal.yml
vim host_vars/apiportal.yml # ... editing
```

Now you can copy the installer to the project and provision your target(s):

```bash
# copy apiportal installation package archive to 
# `resources` directory. in order ansible to autodetect the
# installation package archive in the `resources` dir it
# must match the pattern "apiportal-*install*.tgz"
cp ~/Downloads/apiportal-installer.tgz ./resources/apiportal-rhel7-install-package.tgz
# run the playbook using the inventory file
ansible-playbook -i inv/prod.yml apiportal.yml
```

You can leave the installer outside of the project and point it with addition option:

```bash
# run the playbook using the inventory file
ansible-playbook -i inv/prod.yml apiportal.yml \
  -e "apiportal_installer=${HOME}/Downloads/apiportal-installer.tgz"
```

[ansible installation]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
