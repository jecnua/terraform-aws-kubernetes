# CHANGELOG

## 5.0.0

### Features & Changes

- Removed nodes management and moved to it's own module
- Removed all unused resources
- Using aws_launch_template now
- Using gp3 for EBS
- Installed falco on nodes

### Bugfixes

- Fixed the audit logs from the api-server

### Known bugs/issues

## 4.1.0

### Features & Changes

- Added etcd-client package in the default installation
- Now ETCD is encrypted at rest with a random password (for now)

### Bugfixes

### Known bugs/issues

## 4.0.0

Only supporting terraform 0.14 from now on. Major (and breaking) changes.

### Features & Changes

- Tested with 1.20.0 and update default version to 1.20.1
- Tested with terraform 0.14.3. Updated min terraform version to 0.14

### Bugfixes

### Known bugs/issues

## 3.0.0

Only supporting terraform 0.13 from now on. Major (and breaking) changes.

### Features & Changes

- Tested with 1.19.0 and update default version to 1.19.4
- Tested with terraform 0.13.4. Updated min terraform version to 0.13
- Both master and node setup use kubeadm configs instead of flags
- Migrating cgroup driver to systemd
- Removed Travis in favour of GitHub actions
- Removing weave in favour of Calico as default CNI
- Installed stern on all nodes
- Added access to nodes via SSM and enable it by default (now ec2 key is optional)
- CIS compliance Master: Enabled audit logs
- CIS compliance Master: Disable profiling via web
- CIS compliance Master: Setting kubelet-certificate-authority in api server
- CIS compliance Node: Protecting kernel settings
- Made the enabled admission controller parametric so you can add more as needed

### Bugfixes

- Fixed a couple of warning during instantiation

### Known bugs/issues

## 2.1.0

New version tested with k8s from 1.15.x to 1.18.2

### Features

- Made the version installable parametric (at long last)
- Tested up to 1.18.8
- Updated default ubuntu AMI to 20.04

### Bugfixes

### Changes

### Known bugs/issues

## 2.0.0

### Features

- Updated k8s to version 1.14.2
- Updated terraform to support 0.12.x (only)

### Bugfixes

### Changes

### Known bugs/issues

## 1.4.1

### Features

- Updated to version 1.13.4

### Bugfixes

### Changes

### Known bugs/issues

## 1.4.0

### Features

- Updated to version 1.13.0

### Bugfixes

- Fixed version of kubelet to be the same as kubeadm

### Changes

- Added the controller nodes sg id as output to allow injection

### Known bugs/issues

## 1.3.2

### Features

### Bugfixes

### Changes

### Known bugs/issues

- Small updates

## 1.3.1

### Features

### Bugfixes

### Changes

- Linted and corrected all the BASH to follow best practices
- Added shellcheck to travis checks

### Known bugs/issues

- Sg are defined inside the module with rules. This will be removed to allow rule injection outside the system

## 1.3.0

### Features

- Updated from version 1.7 to 1.12
- Updated ubuntu to 18.04

### Bugfixes

- Fixed the problem with the nodes not joining the master

### Changes

### Known bugs/issues

- Sg are defined inside the module with rules. This will be removed to allow rule injection outside the system

## 1.2.1

### Features

### Bugfixes

-Now the region used by AWS cli inside the bootstrap is parametric

### Changes

### Known bugs/issues

- Sg are defined inside the module with rules. This will be removed to allow rule injection outside the system

## 1.2.0

Updated networking to follow best practices :)

### Features

- Major refactor of the networking
- Removed inline routes from the subnet route tables (the ids are now in the output)
- The worker nodes resources are now removed if you pass 0 nodes as input

### Bugfixes

### Changes

### Known bugs/issues

- Sg are defined inside the module with rules. This will be removed to allow rule injection outside the system

## 1.1.0

### Features

- Made it work in a new environement
- A lot of refactoring

### Bugfixes

### Changes

### Known bugs/issues

- Sg are defined inside the module with rules. This will be removed to allow rule injection outside the system
- Subnets number is limited to two

## 1.0.0

- Opensourced
- Better readme
- Added type and description to all the variables (required and defaults)
- Added MIT license
- Started to comment the code

### Features

### Bugfixes

### Changes

### Known bugs/issues

- Sg are defined inside the module with rules. This will be removed to allow rule injection outside the system
- Subnets number is limited to two
