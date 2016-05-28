# System Users (`system-users`)

Master: [![Build Status](https://semaphoreci.com/api/v1/bas-ansible-roles-collection/system-users/branches/master/badge.svg)](https://semaphoreci.com/bas-ansible-roles-collection/system-users)
Develop: [![Build Status](https://semaphoreci.com/api/v1/bas-ansible-roles-collection/system-users/branches/develop/badge.svg)](https://semaphoreci.com/bas-ansible-roles-collection/system-users)

Creates one or more operating system users with various optional attributes.

**Part of the BAS Ansible Role Collection (BARC)**

**This role uses version 0.2.0 of the BARC flavour of the BAS Base Project - Pristine**.

## Overview

* creates, or removes, one or more operating system users accounts
* optionally, sets a number of user account attributes such as UID, comment, shell, etc.
* optionally, adds more or more public key files to the `authorized_keys` file of a user account
* optionally, sets the primary group of a user account to an existing operating system group
* optionally, sets the secondary groups for a user account to one or more existing operating system groups
* optionally, adds a user account to the relevant sudo group for each operating system to grant sudo privileges

## Quality Assurance

This role uses manual and automated testing to ensure its features work as advertised.
See [here](tests/README.md) for more information.

## Ansible compatibility

* this role supports Ansible 1.8 or higher in the 1.x series
* this role supports Ansible 2.x

**Note:** Support for Ansible 1.x is deprecated by this role, future versions will support Ansible 2.x only. More
information on Ansible compatibility is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Ansible-compatbility)

## Dependencies

* none

More information on role dependencies is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Role-dependencies)

## Requirements

* public keys for user accounts **MUST** exist at the path specified when configuring this role
* secondary groups must, or non-user primary groups **MUST** already exist as operating system groups

More information on role requirements is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Role-requirements)

## Limitations

* authorised keys must be expressed as individual public key files

This means you cannot just rely on the contents of a directory to dynamically control which public keys will be added
as authorised keys. You would also need to update the `authorized_keys_files` list accordingly.

*This limitation is **NOT** considered to be significant. Solutions will **NOT** be actively pursued.*
*Pull requests to address this will be considered.*

See [BARC-61](https://jira.ceh.ac.uk/browse/BARC-61) for further details.

* authorized_keys files must be located at the conventional path `~/.ssh/authorized_keys`

This conventional path is currently hard-coded (as `/home/[username]/.ssh/authorized_keys`) so that role tests can
ensure the ownership and permissions of the `.ssh` directory and `.ssh/authorized_keys` file are properly set.

*This limitation is **NOT** considered to be significant. Solutions will **NOT** be actively pursued.*
*Pull requests to address this will be considered.*

See [BARC-63](https://jira.ceh.ac.uk/browse/BARC-63) for further details.

* authorised keys cannot be removed, only added

It is not possible to indicate whether a public key should be added or removed from a users authorized_keys file. It is
assumed keys will always be added.

*This limitation is considered to be significant. Solutions will be actively pursued.*
*Pull requests to address this will be gratefully considered and given priority.*

See [BARC-64](https://jira.ceh.ac.uk/browse/BARC-64) for further details.

* some variables in this role cannot be easily overridden

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

* it is not possible to remove, or replace, secondary groups for a user

Consider a user:

```yaml
---

system_users_users:
  -
    username: user1
    secondary_groups:
      - a
      - b
```

Secondary groups can only be accumulated using this role, meaning:

* it is possible to make a *user1* a member of group *c*, through some other play
* it is NOT possible remove *user1* from groups *a* or *b*, or *c*, if this was later added
* it is NOT possible to replace group *a* with a group *d* for *user1* (i.e. become part of 'b', 'd' only)

In the case of BAS projects this is not considered to be a big problem as secondary group changes (excluding additions,
which role supports) are expected to be relatively rare, and if needed would be an acceptable reason to recreate any
affected infrastructure - or use a one-off playbook to make the required changes outside of this role.

*This limitation is **NOT** considered to be significant. Solutions will **NOT** be actively pursued.*
*Pull requests to address this will be considered.*

See [BARC-109](https://jira.ceh.ac.uk/browse/BARC-109) for further details.

More information on role limitations is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Role-limitations)

## Usage

### BARC Manifest

By default, BARC roles will record that they have been applied to a system, this is termed the BAS Manifest.
The specific local facts set for this role are:

* `ansible_local.barc_system_users.general.role_applied` - (boolean) records whether a role has been applied
* `ansible_local.barc_system_users.general.role_version` - (string) records the version of the role that was applied

**Note:** You **SHOULD** use this feature to determine whether this role has been applied to a system.
If you do not want these facts to be set by this role, you **MUST** skip the **BARC_SET_MANIFEST** tag.

More information is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Role-Manifest)

### Public keys or passwords

This role supports two methods of authenticating users:

1. public/private keys, uses a public/private key-pair to authenticate, authorised public keys are managed by this role
2. passwords, uses a string to authenticate, user passwords are managed by the operating system

Public/private keys **SHOULD** be used as it is
[generally considered best practice](http://security.stackexchange.com/questions/3887/is-using-a-public-key-for-logging-in-to-ssh-any-better-than-saving-a-password).

Systems operated by BAS **MUST** support public/private keys, and **MAY** support passwords where this is required.

**Note:** Future versions of this role will deprecate password support as soon as feasible.

### Secondary groups

This role supports ensuring users are members of whichever secondary groups are set in the `secondary_groups` option of
a user.

**Note** See the *Sudo users* section if a user should be granted sudo privileges.

Secondary group assignments are cumulative and it is not possible to remove a user from a secondary group they have
previously been a member of. A workaround for this would be to remove the user and re-add them with the reduced, or
altered, set of secondary groups.

This is considered a limitation, see the *Limitations* section for more information.

**Note:** This does not apply to the primary group, which can only be the value of the `primary_group` option,
if specified.

### Sudo users

This role supports assigning sudo privileges to specified users by adding them to the relevant group on each supported
operating system.

Although secondary group memberships are managed generally by this role, specific support for sudo users has been
included to make this common use-case less complicated, by removing the need to determine which group a user should be
added to on each operating system.

See [BARC-108](https://jira.ceh.ac.uk/browse/BARC-108) for background information on why this feature was added.

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
        comment: Connie Watson
        shell: /bin/bash
        authorized_keys_files:
          - "../public_keys/conwat_id_rsa.pub"
        secondary_groups:
          - adm
        state: present
  roles:
    - bas-ansible-roles-collection.system-users
```

### Tags

BARC roles use standardised tags to control which aspects of an environment are changed by roles.
Tasks in this role will 'tag' themselves with these tags as appropriate, typically in `tasks/main.yml`.

More information is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Appendix-B---BARC-Standardised)

### Variables

#### *system_users_barc_role_name*

* **MUST NOT** be specified
* Specifies the name of this role within the BAS Ansible Roles Collection (BARC) used for setting local facts
* See the *BARC roles manifest* section for more information
* Example: `system_users`

#### *system_users_barc_role_version*

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

More information is also available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Issue-Tracking)

### Source code

All changes should be committed, via pull request, to the canonical repository:

`ssh://git@stash.ceh.ac.uk:7999/barc/ROLE-NAME.git`

A read-only mirror of this repository is maintained on GitHub:

`git@github.com:bas-ansible-roles-collection/ROLE-NAME.git`

More information is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Source-Code)

### Contributing policy

This project welcomes contributions, see `CONTRIBUTING.md` for our general policy.

### Release procedure

The general release procedure for BARC roles is available in the
[BARC General Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Release-procedures)

## Licence

Copyright 2016 NERC BAS.

Unless stated otherwise, all documentation is licensed under the Open Government License - version 3.
All code is licensed under the MIT license.

Copies of these licenses are included within this project.
