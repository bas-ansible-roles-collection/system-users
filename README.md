# System Users (`system-users`)

Creates one or more operating system users with various optional attributes.

## Requirements

* Public keys must already exist if using the authorized_keys feature

## Limitations

* The `authorized_keys_files` option must be specified for all system users, regardless of whether the authorized_keys 
feature is used for that user

This occurs because of the 
[sub-elements loop](http://docs.ansible.com/ansible/playbooks_loops.html#looping-over-subelements) used for managing
authorised keys. An [issue](https://github.com/ansible/ansible/issues/9827) is open for this exact problem, but is 
unlikely to be fixed until Ansible 2.0.

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


*This limitation is considered to be significantly limiting, and a solution will be actively pursued. Pull requests 
to address this will be gratefully considered and given priority.*

* Authorised keys must be expressed as individual public key files inside the same directory

It is not possible to use all files within the directory set by `authorized_keys_directory`, or to set public keys 
using in-line values. It is also not possible to use public key files contained in multiple directories due to a 
hard-coded [file lookup](http://docs.ansible.com/ansible/playbooks_lookups.html#intro-to-lookups-getting-file-contents) 
in the form: `lookup('file', [authorized_keys_directory] + '/' + [authorized_key])`.

This means you cannot use the contents of a directory to dynamically control which public keys will be added as
authorised keys. Instead you would also need to manage the `authorized_keys_files` list accordingly.


*This limitation is considered to be significantly limiting, and a solution will be actively pursued. Pull requests 
to address this will be gratefully considered and given priority.*

* The authorized_keys file must be located at the conventional path `~/.ssh/authorized_keys`

This conventional path is currently hard-coded (as `/home/[username]/.ssh/authorized_keys`) so that role tests can
ensure the ownership and permissions of the `.ssh` directory and `.ssh/authorized_keys` file are properly set.


*This limitation is **not** considered to be significantly limiting, and a solution will not be actively pursued. Pull 
requests addressing this will be considered however.*

* Authorised keys cannot be removed, only added

It is not possible to indicate whether a public key should be added or removed from a users authorized_keys file. It is
assumed keys will always be added.


*This limitation is considered to be significantly limiting, and a solution will be actively pursued. Pull requests 
to address this will be gratefully considered and given priority.*

## Usage

### Setting default options

TODO: Describe (its not possible to chain the 'default' filter to try multiple values).

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
