# Copyright 2016, AT&T, and it's Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Kubernetes Details: Instances
$kube_version      = "ubuntu/xenial64"
$kube_memory       = 1024
$kube_disk         = 10
$kube_vcpus        = 1
$kube_count        = 3
$git_commit        = "6a7308d"
$subnet            = "192.168.236"
$public_iface      = "enp0s8"
$forwarded_ports   = {}

# Virtualbox instance additional disk properties:
$disk_enabled      = true
$disk_location     = "~/VirtualBox VMs/"
$disk_image_file   = "vmdk"
#$disk_mountname    = "xfs"
#$disk_mountpoint   = "/mnt/xfs"

# Ansible Declarations:
#$number_etcd       = "kube[1:2]"
#$number_master     = "kube[1:2]"
#$number_worker     = "kube[1:3]"
$kube_masters      = "kube1"
$kube_workers      = "kube[2:3]"
$kube_control      = "kube1"

# Virtualbox leave / Openstack change to OS default username:
$ssh_user          = "ubuntu"
$ssh_keypath       = "~/.ssh/id_rsa"
$ssh_port          = 22

# Ansible Details:
$ansible_limit     = "all"
$ansible_playbook  = "halcyon-kubernetes/kube-deploy/kube-deploy.yml"
$ansible_inventory = ".vagrant/provisioners/ansible/inventory_override"

# Openstack Authentication Information:
$os_auth_url       = "http://your.openstack.url:5000/v2.0"
$os_username       = "user"
$os_password       = "password"
$os_tenant         = "tenant"

# Openstack Instance Information:
$os_flavor         = "m1.small"
$os_image          = "ubuntu-trusty-16.04"
$os_floatnet       = "public"
$os_fixednet       = ['vagrant-net']
$os_keypair        = "your_ssh_keypair"
$os_secgroups      = ["default"]

# Proxy Configuration (only use if deploying behind a proxy):
$proxy_enable      = false
$proxy_http        = "http://proxy:8080"
$proxy_https       = "https://proxy:8080"
$proxy_no          = "localhost,127.0.0.1"
