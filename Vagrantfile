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

# -*- mode: ruby -*-
# vi: set ft=ruby :
# NOTE: Variable overrides are in ./config.rb
require "yaml"
require "fileutils"

# Use a variable file for overrides:
CONFIG = File.expand_path("config.rb")
if File.exist?(CONFIG)
  require CONFIG
end

# Force best practices for this environment:
if $kube_memory < 512
  puts "WARNING: Your machine should have at least 512 MB of memory"
end

if $kube_disk < 10
  puts "WARNING: Your machine disk size should be at least 10 GB"
end

# Install any Required Plugins
missing_plugins_installed = false
required_plugins = %w(vagrant-env vagrant-git vagrant-openstack-provider vagrant-proxyconf vagrant-persistent-storage)

required_plugins.each do |plugin|
  if !Vagrant.has_plugin? plugin
    system "vagrant plugin install #{plugin}"
    missing_plugins_installed = true
  end
end

# If any plugins were missing and have been installed, re-run vagrant
if missing_plugins_installed
  exec "vagrant #{ARGV.join(" ")}"
end

# Use plugins after install / re-run
require "vagrant-openstack-provider"

# Vagrantfile API/sytax version. Don’t touch unless you know what you’re doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

# UNCOMMENT FOLLOWING LINES FOR OPENSTACK PROVIDER:
#if provider == "openstack"
#   config.ssh.username         = $ssh_user
#   config.ssh.private_key_path = $ssh_keypath
#end
# DO NOT ADD YET!!!
#  config.ssh.username         = $ssh_user
#  config.ssh.private_key_path = $ssh_keypath

  # Guest Definitions:
  # ------------------------
  #
  # START: Kube Definition(s)
  (1..$kube_count).each do |kb|
  ip = "#{$subnet}.#{kb}"

    config.vm.define vm_name = "kube#{kb}" do |kube|

      kube.vm.box = $kube_version
      kube.vm.hostname = "kube#{kb}"
      # NETWORK-SETTINGS: eth1 configured in using the $subnet variable:
      kube.vm.network "private_network", ip: "172.16.35.1#{kb}", auto_config: true
#      kube.vm.network "public_network", ip: "#{$subnet}.#{kb}"
      if $proxy_enable
        config.proxy.http     = $proxy_http
        config.proxy.https    = $proxy_https
        config.proxy.no_proxy = $proxy_no
      end

      if $expose_docker_tcp
        kube.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end
      $forwarded_ports.each do |guest, host|
        kube.vm.network "forwarded_port", guest: guest, host: host, auto_correct: true
      end
      # Virtualbox Provider (Default --provider=virtualbox):
      kube.vm.provider "virtualbox" do |vb|
        vb.name = "kube#{kb}"
        vb.customize ["modifyvm", :id, "--memory", $kube_memory]
        vb.customize ["modifyvm", :id, "--cpus", $kube_vcpus]
        if $kube_disk > 10 #Attach additional disk
          kube.persistent_storage.enabled = $disk_enabled
          kube.persistent_storage.location = $disk_location+"kube#{kb}."+$disk_image_file
          kube.persistent_storage.size = $kube_disk * 1024 - 10240
        end
      end
      # Libvirt Provider (Optional --provider=libvirt)
      kube.vm.provider "libvirt" do |lv|
        lv.driver = "kvm"
        lv.memory = $kube_memory
        lv.cpus = $kube_vcpus
        lv.machine_virtual_size = $kube_disk
      end
      # Openstack Provider (Optional --provider=openstack):
      kube.vm.provider "openstack" do |os|
        # Openstack Authentication Information:
        os.openstack_auth_url  = $os_auth_url
        os.username            = $os_username
        os.password            = $os_password
        os.tenant_name         = $os_tenant
        # Openstack Instance Information:
        os.server_name         = "kube#{kb}"
        os.flavor              = $os_flavor
        os.image               = $os_image
        os.floating_ip_pool    = $os_floatnet
        os.networks            = $os_fixednet
        os.keypair_name        = $os_keypair
        os.security_groups     = $os_secgroups
      end
    # We only want Ansible to run after after all servers are deployed:
    if kb == $kube_count
      kube.vm.provision :ansible do |ansible|
        ansible.sudo              = true
        ansible.limit             = $ansible_limit
        ansible.playbook          = $ansible_playbook
        ansible.host_key_checking = false
        ansible.groups            = {
          # Kube-Master hosts (currently kubeadm limitations to kube1):
          "kube-masters" => [$kube_masters],
          # Kube-Worker hosts (all):
          "kube-workers" => [$kube_workers],
          # Kube-Control is your primary `kubectl` host:
          "kube-control" => [$kube_control],
          "kube-cluster:children" => ["kube-masters", "kube-workers"],
        }
        ansible.extra_vars        = {
          "public_iface" => $public_iface,
          "proxy_enable" => $proxy_enable,
          "proxy_http" => $proxy_http,
          "proxy_https" => $proxy_https,
          "proxy_no" => $proxy_no
        }
        # Additional Ansible tools for debugging:
        #ansible.inventory_path = $ansible_inventory
        #ansible.verbose        = "-vvvv"
        #ansible.raw_ssh_args   = ANSIBLE_RAW_SSH_ARGS
        end
      end
    end
  end
end
