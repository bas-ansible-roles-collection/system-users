# System Users (`system-users`) - Testing

## Overview

To ensure this role works correctly, tests **MUST** be written for any role changes. Roles must pass their tests before
new versions are released.

These tests, and their different configurations, aim to cover the most frequent, and not all, ways a role is used using
multiple environments.

* General information on how BARC roles are tested is available in the
[BARC Overview and Polices Documentation](https://antarctica.hackpad.com/BARC-Overview-and-Policies-SzcHzHvitkt#:h=Testing)
* The structure and implementation of these tests is described in more detail in the
[Pristine - BARC Flavour documentation](https://paper.dropbox.com/doc/BAS-Base-Project-Pristine-BARC-Flavour-07j1BJt65gs2crIhMgWhw#:h=Role-testing)
* Details on the testing environments these tests are ran within are described in more detail in the [Pristine - BARC Flavour documentation](https://paper.dropbox.com/doc/BAS-Base-Project-Pristine-BARC-Flavour-07j1BJt65gs2crIhMgWhw#:h=Role-testing)

The *Testing* environment tests a single scenario:

* Two users are created, the first with optional settings, an authorised key and custom primary and secondary groups
and sudo privileges, the second, only with required options, no authorised keys and the default primary and no
secondary groups

The *Local Testing* environment tests multiple scenarios:

1. Two users are created
  * the first with:
    * optional settings set
    * an authorised key
    * a password
    * specified primary and secondary groups [1]
    * sudo privileges
  * the second with:
    * only required options
    * no authorised key
    * no password
    * no specified primary or secondary groups
    * no privileges
2. A user is created, with required options only, a second, pre-existing, user is removed [2]

[1] Due to the way this scenario is implemented, idempotency is not checked.

[2] It currently isn't possible to test if a user is added to multiple secondary groups as the output of the groups
in both lists (i.e. the groups a user is in and list of groups the user should be in) are not predicable. This means
it isn't possible to write a test condition to check if both lists are the same. However can check if the user is in at
least one secondary group, which should hopefully be enough to verify the concept works.

**Note:** *Local Testing* environments test scenarios on all operating systems this role supports. Services providing
*Testing* environments may limit which operating system are available (e.g. SemaphoreCI only supports Ubuntu Trusty).

## Setup

To bring up a local testing environment:

1. Ensure you meet all the
[requirements](https://paper.dropbox.com/doc/BAS-Base-Project-Pristine-Base-Flavour-Usage-ZdMdHHzf8xB4HjxcNuDXa#:h=Environment---local-testing)
to bring up a local testing environment
2. `$ cd system-users/tests/provisioning/site-testing-local`
3. `$ vagrant up`
4. `$ cd ..`
5. `$ ansible-playbook site-testing-local.yml`

To bring up the testing environment:

1. Ensure you meet all the [requirements](https://paper.dropbox.com/doc/BAS-Base-Project-Pristine-Base-Flavour-Usage-ZdMdHHzf8xB4HjxcNuDXa#:h=Environment---testing)
to bring up a testing environment
2. Ensure you have performed all the [setup tasks](https://paper.dropbox.com/doc/BAS-Base-Project-Pristine-Base-Flavour-Usage-ZdMdHHzf8xB4HjxcNuDXa#:h=Environment---testing)
for the testing environment

Note: This role uses *SeamphoreCI* as its Continuous Integration service.

## Usage

To run tests using a local testing environment:

1. `$ cd system-users/tests/provisioning`
2. `$ ansible-playbook app-test-local.yml`

To run tests using a remote testing environment:

* No action is needed other than committing changes to the role repository, tests will then run automatically

Results for these tests can be found [here](https://semaphoreci.com/bas-ansible-roles-collection/system-users).
