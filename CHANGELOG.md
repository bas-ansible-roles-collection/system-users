# System Users (`system-users`) - Change log

All notable changes to this role will be documented in this file.
This role adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][unreleased]

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
