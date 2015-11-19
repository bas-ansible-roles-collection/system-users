## Why is there something in this directory?

The file, `antarctica.prelude/meta/main.yml`, needs to be in this directory for Ansible Galaxy to function correctly.

## Why?

Without this file Ansible Galaxy assumes this 'fake' role is corrupt and refuses to overwrite it with the 'real' role 
(for reasons known only to itself). This file is therefore used strictly as a workaround to this problem.

## What is the 'fake' role?

To Ansible, the minimum needed for something to be considered a role is a `main.yml` file inside a `meta` directory.
This 'fake' role is obviously not the actual prelude role, that will be downloaded by Ansible Galaxy as normal.
