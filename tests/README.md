# System Users (`system-users`) - Testing

## Overview

To ensure this role works correctly, tests **MUST** be written for any role changes. Roles must pass their tests before 
new versions are released. Both manual and automated methods are used to test this role.

These tests, and their different configurations, aim to cover the most frequent, and not all, ways a role is used. 

Three aspects of this role are tested:

1. **Valid role syntax** - as determined by `ansible-playbook --syntax-check`
2. **Functionality** - I.e. does this role do what it claims to 
3. **Idempotency** - I.e. do any changes occur if this role is applied a second time

Tests for these aspects can be split into:

* **Test tasks** - act like unit tests by testing each task to ensure it functions correctly
* **Test playbooks** - act like integration tests by combining tasks in various scenarios

Test tasks mirror the structure of the `tasks` directory within the main role.
A playbook is applied to a number of test VMs to run a number of different scenarios, using host variables.

Playbooks, host variables and other support files are kept in this `tests` directory.

A single scenario is tested using *Continuous Integration*:

* Two users are created, the first with optional settings, an authorised key and custom primary and secondary groups,
the second, only with required options, no authorised keys and the default primary and no secondary groups

Multiple scenarios are tested *manually*:

1. `test-users` - Creates two users, the first with optional settings, the second only with required options
2. `test-users` - Creates two users, the first including an authorised key, the second without
3. `test-remove` - Creates a new user, required options only, and removes a pre-existing user [1]
4. `test-groups` - Creates two users, the first with custom primary and secondary groups, the second with a default
primary group and no secondary groups [2]

Note: Multiple scenarios may be run within the same VM, providing they do not overlap.

Manually run scenarios are run on all Operating Systems this role supports. Continuous Integration scenarios only run 
on Ubuntu Trusty (14.04).

[1] Due to the way this scenario is implemented, idempotency is not checked.

[2] It currently isn't possible to test if a user is added to multiple secondary groups as the output of the groups
in both lists (i.e. the groups a user is in and list of groups the user should be in) are not predicable. This means
it isn't possible to write a test condition to check if both lists are the same. However can check if the user is in at
least one secondary group, which should hopefully be enough to verify the concept works.

## Continuous Integration

[SemaphoreCI](https://semaphoreci.com/) is used for Continuous Integration in this role. Pushing changes to this roles 
repository will automatically trigger Semaphore to run a set of tests. These tests will run a single scenario, 
indicated previously.

Note: It is currently only possible to test a single scenario, as we cannot wipe the test VM during the test process.

### Requirements

To *setup* this service:

* Suitable permissions within [SemaphoreCI](https://semaphoreci.com) to create projects under the 
*bas-ansible-roles-collection* organisation [1]

To *use* this service:

* Suitable permissions to push to the *develop* branch of the project repository [1]
* Suitable permissions within [SemaphoreCI](https://semaphoreci.com) to view projects under the 
*bas-ansible-roles-collection* organisation [1]

[1] Please contact the *Project Maintainer* if you do not have these permissions.

### Setup

If not added already, create a new project in [SemaphoreCI](https://semaphoreci.com) using the `develop` branch of the
Project Repository and associate within the *bas-ansible-roles-collection* organisation. Repeat this for the *master* 
branch when ready.

If the project already exists, but not this branch, check the settings below are correct and add the *develop* branch
as a new build branch manually. Repeat this for the *master* branch when ready.

In the settings for this project set the *Build Settings* to:

* Language: *Python*
* Version: *2.7*

For the *Setup* thread enter these commands:

```shell
cd tests
pip install ansible==1.9.4
```

For *Thread #1* rename to *Build and Test* with these commands:

```shell
ansible-playbook provisioning/site-ci.yml --syntax-check
ansible-playbook provisioning/site-ci.yml --connection=local
ansible-playbook provisioning/site-ci.yml --connection=local | tee /tmp/output.txt; grep -q 'changed=0.*failed=0' /tmp/output.txt && (echo 'Idempotence test: pass' && exit 0) || (echo 'Idempotence test: fail' && exit 1)
```

Set the *Branches* settings to:

* Build new branches: `Never`

Copy the build badge for the *develop* and *master* (when ready) branch to this README.

If the project and branch already exists, check the settings above are correct.

### Usage

Pushing to the `develop` or *master* (when ready) branch will automatically trigger SemaphoreCI, test results are 
available [here](https://semaphoreci.com/bas-ansible-roles-collection/system-users).

## Manual tests

Manual tests are more complete than Continuous Integration, by testing all test scenarios. These tests are therefore 
slower and more time consuming to run than CI tests. The use of Ansible and simple shell scripts aims to reduce this 
effort/complexity as far as is practical.

### Requirements

#### All environments

* Mac OS X or Linux
* [VMware Fusion](http://vmware.com/fusion) `brew cask install vmware-fusion` [1] [2]
* [Vagrant](http://vagrantup.com) `brew cask install vagrant` [1] [2]
* Vagrant plugins:
    * [Vagrant VMware](http://www.vagrantup.com/vmware) `vagrant plugin install vagrant-vmware-fusion`
    * [Host manager](https://github.com/smdahlen/vagrant-hostmanager) `vagrant plugin install vagrant-hostmanager`
* [Git](http://git-scm.com/) `brew install git` [3] [2]
* [Ansible](http://www.ansible.com) `brew install ansible` [3] [2]
* You have a [private key](https://help.github.com/articles/generating-ssh-keys/) `id_rsa`
and [public key](https://help.github.com/articles/generating-ssh-keys/) `id_rsa.pub` in `~/.ssh/`
* You have an entry like [4] in your `~/.ssh/config`

[1] `brew` is a package manager for Mac OS X, see [here](http://brew.sh/) for details.

[2] Although these instructions uses `brew` and `brew cask` these are not required, 
binaries/packages can be installed manually if you wish.

[3] `brew cask` is a package manager for Mac OS X binaries, see [here](http://caskroom.io/) for details.

[4] SSH config entry

```shell
Host *.v.m
    ForwardAgent yes
    User app
    IdentityFile ~/.ssh/id_rsa
    Port 22
```

### Setup

It is assumed you are in the root of this role.

```shell
cd tests
```

VMs are powered by VMware, managed using Vagrant and configured by Ansible.

```shell
$ vagrant up
```

Vagrant will automatically configure the localhost hosts file for infrastructure it creates on your behalf:

| Name                                 | Points To         | FQDN                                       | Notes                       |
| ------------------------------------ | ----------------- | ------------------------------------------ | --------------------------- |
| barc-system-users-test-ubuntu-users  | *computed value*  | `barc-system-users-test-ubuntu-users.v.m`  | The VM's private IP address |
| barc-system-users-test-centos-users  | *computed value*  | `barc-system-users-test-centos-users.v.m`  | The VM's private IP address |
| barc-system-users-test-ubuntu-remove | *computed value*  | `barc-system-users-test-ubuntu-remove.v.m` | The VM's private IP address |
| barc-system-users-test-centos-remove | *computed value*  | `barc-system-users-test-centos-remove.v.m` | The VM's private IP address |
| barc-system-users-test-ubuntu-groups | *computed value*  | `barc-system-users-test-ubuntu-groups.v.m` | The VM's private IP address |
| barc-system-users-test-centos-groups | *computed value*  | `barc-system-users-test-centos-groups.v.m` | The VM's private IP address |

Note: Vagrant managed VMs also have a second, host-guest only, network for management purposes not documented here.

### Usage

Use this shell script to run all test phases automatically:

```shell
$ ./tests/run-local-tests.sh
```

Alternatively run each phase separately:

```shell
# Check syntax:
$ ansible-playbook provisioning/site-test.yml --syntax-check

# Apply playbook:
$ ansible-playbook provisioning/site-test.yml

# Apply again to check idempotency:
# Note: The 'remove user' scenario is permitted to fail this check
$ ansible-playbook provisioning/site-test.yml
```

Note: The use of `#` in the above indicates a comment, not a root shell.

### Clean up

```shell
$ vagrant destroy
```
