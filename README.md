# System Users (`system-users`)

Master:
[![Build Status](https://semaphoreci.com/api/v1/bas-ansible-roles-collection/system-users/branches/master/badge.svg)](https://semaphoreci.com/bas-ansible-roles-collection/system-users)

Develop:
[![Build Status](https://semaphoreci.com/api/v1/bas-ansible-roles-collection/system-users/branches/develop/badge.svg)](https://semaphoreci.com/bas-ansible-roles-collection/system-users)

Creates one or more operating system users with various optional attributes.

**Part of the BAS Ansible Role Collection (BARC)**

## Overview

* Creates, or removes, one or more operating system users accounts
* Optionally, sets a number of user account attributes such as UID, comment, shell, etc.
* Optionally, adds more or more public key files to the `authorized_keys` file of a user account
* Optionally, sets the primary group of a user account to an existing operating system group
* Optionally, sets the secondary groups for a user account to one or more existing operating system groups
* Optionally, adds a user account to the relevant sudo group for each operating system to grant sudo privileges

## Quality Assurance

This role uses manual and automated testing to ensure the features offered by this role work as advertised. 
See `tests/README.md` for more information.

## Dependencies

* None

## Requirements

* If adding public keys to a user account, these must already exist on your local machine
* If setting the primary group or secondary groups for a user account, these must already exist as operating system
groups

## Limitations

* The `authorized_keys_files` option must be specified for all system users, regardless of whether the authorized_keys 
feature is used for that user

This occurs because of the 
[sub-elements loop](http://docs.ansible.com/ansible/playbooks_loops.html#looping-over-subelements) used for managing
authorised keys. An issue is open for this exact problem, but is unlikely to be fixed until Ansible 2.0.

Where you are not managing the authorised keys for a user with this role, this variable can be safely set to an empty
list. This role will only apply changes to a users authorised keys file where the `authorized_keys_directory` is 
defined for a user.

E.g.

```yaml
---

# In this example the user 'user' does not have authorised keys managed by this role as the 'authorized_keys_directory'
# option is missing. To prevent Ansible complaining about an undefined variable used in a sub-elements loop, an empty
# list is set for 'authorized_keys_files' option.

# System Users
system_users_users:
  -
    username: user
    authorized_keys_files: []
```

*This limitation is considered to be significant. Solutions will be actively pursued.*
*Pull requests to address this will be gratefully considered and given priority.*

See [#9827](https://github.com/ansible/ansible/issues/9827) for further information of this upstream bug.

See [BARC-62](https://jira.ceh.ac.uk/browse/BARC-62) for further details.

* Authorised keys must be expressed as individual public key files inside the same directory

It is not possible to use all files within the directory set by `authorized_keys_directory`, or to set public keys 
using in-line values. It is also not possible to use public key files contained in multiple directories due to a 
hard-coded [file lookup](http://docs.ansible.com/ansible/playbooks_lookups.html#intro-to-lookups-getting-file-contents) 
in the form: `lookup('file', [authorized_keys_directory] + '/' + [authorized_key])`.

This means you cannot use the contents of a directory to dynamically control which public keys will be added as
authorised keys. Instead you would also need to manage the `authorized_keys_files` list accordingly.

*This limitation is considered to be significant. Solutions will be actively pursued.*
*Pull requests to address this will be gratefully considered and given priority.*

See [BARC-61](https://jira.ceh.ac.uk/browse/BARC-61) for further details.

* The authorized_keys file must be located at the conventional path `~/.ssh/authorized_keys`

This conventional path is currently hard-coded (as `/home/[username]/.ssh/authorized_keys`) so that role tests can
ensure the ownership and permissions of the `.ssh` directory and `.ssh/authorized_keys` file are properly set.

*This limitation is **NOT** considered to be significant. Solutions will **NOT** be actively pursued.*
*Pull requests to address this will be considered.*

See [BARC-63](https://jira.ceh.ac.uk/browse/BARC-63) for further details.

* Authorised keys cannot be removed, only added

It is not possible to indicate whether a public key should be added or removed from a users authorized_keys file. It is
assumed keys will always be added.

*This limitation is considered to be significant. Solutions will be actively pursued.*
*Pull requests to address this will be gratefully considered and given priority.*

See [BARC-64](https://jira.ceh.ac.uk/browse/BARC-64) for further details.

* Some variables in this role cannot be easily overridden

This specifically affects: *os_sudo_group*.

Values for these variables vary on each supported operating system and therefore cannot be defined as variables in 
`defaults/main.yml` (which are universal). Ansible does not support conditionally importing additional variables at 
the same priority of role 'defaults' (i.e. variables defined in `defaults/main.yml`), therefore these variables must be 
set in `vars/` within this role, and conditionally loaded using the 
[include_vars module](http://docs.ansible.com/ansible/include_vars_module.html).

Variables set at this priority cannot be easily overridden in playbooks (i.e. using the `vars` option), or in variable 
files (i.e. using the `vars_files` option). In fact only 'extra_vars' set on the command line can override variables of
this precedence.

Given the nature of these variables, it is not expected likely users will need (or want) to changes the values for these
variables, and therefore the difficultly needed to override them is considered an acceptable, and not significant 
limitation. However, if other variables need to be defined in this way this may need to revisited in the future.

*This limitation is **NOT** considered to be significant. Solutions will **NOT** be actively pursued.*
*Pull requests to address this will be considered.*

See the 
[Ansible Documentation](http://docs.ansible.com/ansible/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable) 
for further details on variable precedence.

See [BARC-93](https://jira.ceh.ac.uk/browse/BARC-93) for further details.

## Usage

### BARC manifest

By default, BARC roles will record that they have been applied to a system. This is recorded using a set of 
[Ansible local facts](http://docs.ansible.com/ansible/playbooks_variables.html#local-facts-facts-d), specifically:

* `ansible_local.barc_system_users.general.role_applied` - to indicate that this role has been applied
* `ansible_local.barc_system_users.general.role_version` - to indicate the applied version of this role

Note: You **SHOULD** use this feature to determine whether this role has been applied to a system.

If you do not want these facts to be set by this role, you **MUST** skip the **BARC_SET_MANIFEST** tag. No support is 
offered in this case, as other roles or use-cases may rely on this feature. Therefore you **SHOULD NOT** disable this
feature.

### Public keys or passwords

This role supports two methods of authenticating as a user:

1. Public keys, uses a public/private key-pair to authenticate, authorised public keys are managed by this role
2. Passwords, uses a string to authenticate, user passwords are managed by the operating system

It is strongly **RECOMMENDED** to the first, public keys, option wherever feasible and is generally considered best 
practice [source](http://security.stackexchange.com/questions/3887/is-using-a-public-key-for-logging-in-to-ssh-any-better-than-saving-a-password).

This role does support setting user passwords where there is no other option, however long term support by this role is
not guaranteed and will be removed if possible in future.

### Typical playbook

```yaml
---

- name: configure system users
  hosts: all
  become: yes
  vars:
    system_users_users:
      -
        username: conwat
        comment: User account for Connie Watson
        shell: /bin/bash
        authorized_keys_directory: "../public_keys"
        authorized_keys_files:
          - "conwat_id_rsa.pub"
        secondary_groups:
          - adm
        state: present
  roles:
    - bas-ansible-roles-collection.system-users
```

### Setting default options

It is not possible to set a 'default' user from which options are inherited [1], however it is possible to re-use 
variables yourself.

E.g.

```yaml
---

system_users_defaults:
  - shell: /bin/bash

system_users_users:
  -
    username: user1
    shell: "{{ system_users_defaults.shell }}"
    state: present
  -
    username: user2
    shell: "{{ system_users_defaults.shell }}"
    state: present
```

[1] It is not possible to chain the `default()` and `omit` filters together, 
e.g. `username: instance_username | default(default_username) | omit`.

### Sudo users

This role supports assigning sudo privileges to specified users by adding them to the relevant group on each supported
operating system.

Although secondary group memberships are managed generally by this role, specific support for sudo users has been 
included to make this common use-case less complicated, by removing the need to determine which group a user should be
added to on each operating system.

See [BARC-108](https://jira.ceh.ac.uk/browse/BARC-108) for background information on why this feature was added.

### Tags

BARC roles use standardised tags to control which aspects of an environment are changed by roles. Where relevant, tags
will be applied at a role, or task(s) level, as indicated below.

This role uses the following tags, for all tasks:

* [**BARC_CONFIGURE**](https://antarctica.hackpad.com/BARC-Standardised-Tags-AviQxxiBa3y#:h=BARC_CONFIGURE)
* [**BARC_CONFIGURE_SYSTEM**](https://antarctica.hackpad.com/BARC-Standardised-Tags-AviQxxiBa3y#:h=BARC_CONFIGURE_SYSTEM)
* [**BARC_CONFIGURE_USERS**](https://antarctica.hackpad.com/BARC-Standardised-Tags-AviQxxiBa3y#:h=BARC_CONFIGURE_USERS)
* [**BARC_SET_MANIFEST**](https://antarctica.hackpad.com/BARC-Standardised-Tags-AviQxxiBa3y#:h=BARC_SET_MANIFEST)

### Variables

#### *system_users_barc_role_name*

* **MUST NOT** be specified
* Specifies the name of this role within the BAS Ansible Roles Collection (BARC) used for setting local facts
* See the *BARC roles manifest* section for more information
* Example: `system_users`

#### *system_users_barc_role_name*

* **MUST NOT** be specified
* Specifies the name of this role within the BAS Ansible Roles Collection (BARC) used for setting local facts
* See the *BARC roles manifest* section for more information
* Example: `2.0.0`

#### *system_users_users*

A list of operating system user accounts, and their properties, to be managed by this role.

* **MAY** be specified

Structured as a list of items, with each item having the following properties:

* *username*
  * **MUST** be specified
  * Values **MUST** be valid user usernames, as determined by the operating system
  * Example: `conwat`
* *uid*
  * **MAY** be specified
  * Specifies whether the user should have a fixed UID, or if should be allocated by the operating system
  * Values **MUST** be valid user UIDs, as determined by the operating system
  * Values **SHOULD** respect operating system conventions for system/non-system users and reserved or special ranges
  * Where not specified, the operating system will assign a suitable UID (i.e. the next in the relevant range)
  * Specifying this property is non-default behaviour
  * Example: `1001`
* *comment*
  * **SHOULD** be specified
  * Values **MUST** be valid user comments, as determined by the operating system
  * Values **SHOULD** be suitably descriptive to aid other users, without being needlessly verbose
  * Where not specified, no comment will be added
  * Example: `User account for Connie Watson`
* *shell*
  * **MAY** be specified
  * Specifies the shell interpreter for a user
  * Values **MUST** be valid shell interpreters (i.e. installed), as determined by the operating system
  * Where not specified, the default interpreter will be used
  * Example: `/bin/bash`
* *authorized_keys_directory*
  * **MAY** be specified if it desired for authorised keys to a added to a user account, otherwise this **MUST NOT** be 
  specified
  * Specifies in which directory the public key files indicated by the *authorized_keys_files* property are located
  * The presence of this property is used to determine whether authorised keys should be managed for the user, i.e. if
  this property is defined, the values in the *authorized_keys_files* property will be used
  * Values **MUST** represent a valid path to a directory, on the Ansible control machine (i.e. localhost), 
  values **MUST** not use a trailing directory separator (i.e. `/`)
  * Example `../public_keys` - assuming this role is within a `roles` directory, this would point to a `public_keys` 
  directory that sits alongside the roles directory
* *authorized_keys_files*
  * **MUST** be specified as a property (see limitations above), however items **MAY** be specified 
  * Specifies the individual public key files that should be added the user's `authorized_keys` file
  * Structured as a list of items, with each item representing the file name of a public key file
  * Item values **MUST** represent valid file names for valid SSH public key files, as determined by SSH, located within 
  the directory set by the *authorized_keys_directory* property
  * Where no public keys should be added for a user, this property can be set to an empty list (i.e. `[]`)
  * Example: `- "conwat_id_rsa.pub"` - of a single item within this property
* *password*
  * **MAY** be specified
  * Specifies the login password for the user, the value will be hashed by this role
  * It is **NOT RECOMMENDED** to use this option, see the notes in the usage section of this role for more information
  * Values **MUST** be valid for use as system passwords, as determined by the operating system
  * Values **MUST** be given in plain text, care **SHOULD** be taken to suitably protect such values from disclosure 
  (i.e. by using encryption)
  * Where not specified, no password will be set, this is **RECOMMENDED**
* *primary_group*
  * **MAY** be specified
  * Specifies whether a pre-existing, named, group should be used for the user's primary group, or if a group named
  after the user's username should be created and used
  * Values **MUST** be the name for a valid group, that already exists, as determined by the operating system
  * Where not specified, the operating system will create a group based on the user's username and use this as the
  primary group
  * Specifying this property is non-default behaviour, it is much more likely you will want to use secondary groups 
  instead
  * Example: `foo`
* *secondary_groups*
  * **MAY** be specified
  * Specifies supplementary (secondary), pre-existing, named, groups the user should be member of
  * Structured as a list of items, with each item representing a secondary group
  * Item values **MUST** represent the name of valid group, that already exists, as determined by the operating system
  * Where no secondary groups should be added for a user, this property can be omitted
  * Example: `- adm` - of a single item within this property
* *sudo*
  * **MAY** be specified
  * Specifies whether a user should be added to the relevant sudo users group to gain sudo privileges
  * Values **MUST** use one of these options, as determined by Ansible:
    * `true`
    * `false`
  * Values SHOULD NOT be quoted to prevent Ansible coercing values to a string
  * Where a user should not have sudo privileges, this property can be omitted
  * Default: `false`
* *state*
  * **SHOULD** be specified
  * Specifies whether the user should be present as user, or absent
  * Values **MUST** use one of these options, as determined by Ansible:
    * `present`
    * `absent`
  * Where not specified it will be assumed the user should be present
  * Example: `present`

Default: `[]` - an empty list

## Developing

### Issue tracking

Issues, bugs, improvements, questions, suggestions and other tasks related to this package are managed through the 
[BAS Ansible Roles Collection](https://jira.ceh.ac.uk/projects/BARC) (BARC) project on Jira.

This service is currently only available to BAS or NERC staff, although external collaborators can be added on request.
See our contributing policy for more information.

### Source code

All changes should be committed, via pull request, to the canonical repository, which for this project is:

`ssh://git@stash.ceh.ac.uk:7999/barc/system-users.git`

A mirror of this repository is maintained on GitHub. Changes are automatically pushed from the canonical repository to
this mirror, in a one-way process.

`git@github.com:bas-ansible-roles-collection/system-users.git`

Note: The canonical repository is only accessible within the NERC firewall. External collaborators, please make pull 
requests against the mirrored GitHub repository and these will be merged as appropriate.

### Contributing policy

This project welcomes contributions, see `CONTRIBUTING.md` for our general policy.

The [Git flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow/) 
workflow is used to manage the development of this project:

* Discrete changes should be made within feature branches, created from and merged back into develop 
(where small changes may be made directly)
* When ready to release a set of features/changes, create a release branch from develop, update documentation as 
required and merge into master with a tagged, semantic version (e.g. v1.2.3)
* After each release, the master branch should be merged with develop to restart the process
* High impact bugs can be addressed in hotfix branches, created from and merged into master (then develop) directly

### Release procedure

See [here](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Release-procedures) for general 
release procedures for BARC roles.

## Licence

Copyright 2015 NERC BAS.

Unless stated otherwise, all documentation is licensed under the Open Government License - version 3. All code is
licensed under the MIT license.

Copies of these licenses are included within this role.
