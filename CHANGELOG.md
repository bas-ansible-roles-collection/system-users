# System Users (`system-users`) - Change log

All notable changes to this role will be documented in this file.
This role adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

Note: Developers - make sure to set the `BARC_role_version` variable when releasing new versions of this role.

## [Unreleased][unreleased]

## 0.3.2 - 05/02/2016

### Fixed

* BARC manifest support updated to fix issues where multiple BARC roles are applied to the same machine
* Typos in BARC manifest documentation

## 0.3.1 - 05/02/2016

### Fixed

* Change log date formatting
* BARC role version variable
* Semaphore organisation URLs

## 0.3.0 - 05/02/2016

### Added

* Local facts to record this role has been applied to a system and its version, plus supporting documentation sections

### Fixed

* Missing instructions for setting up CI for the master branch
* README formatting and typos
* Minor corrections to other files for formatting and typos
* Pinning Ansible to pre-2.0 version in CI
* Missing testing information for lack of functional tests

### Changed

* Name of CI playbook to fit with new conventions
* Migrating from old Ansible Galaxy namespace, 'BARC', to 'bas-ansible-roles-collection'
* Migrating from old Ansible Galaxy 'categories' to new 'tags' meta-data
* Migrating from old Repository in 'antarctica' to 'bas-ansible-roles-collection'
* Migrating from old Semaphore 'antarctica' organisation to 'bas-ansible-roles-collection'
* Simplifying CI setup tasks

## 0.2.0 - 19/11/2015

### Added

* An option to set the password for a user - tests do not verify the correct password value was used, this is assumed
* Experimenting with Git attributes file to produce cleaner release archives and improve language stats on GitHub

### Fixed

* Repository information in testing group vars
* README formatting and typos
* Fixing role namespace in README, we are now 'BARC' not 'antarctica'
* Correcting testing README

### Changed

* Improved comments for testing scripts
* Updating testing provisioning to new conventions

### Removed

* Redundant groups from testing inventory file

## 0.1.0 - 12/11/2015

### Added

* Initial version - with support for users, common user properties, authorised keys (append only) and 
groups (must pre-exist)
