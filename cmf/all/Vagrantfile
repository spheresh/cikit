# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

require "yaml"

isWindows = Vagrant::Util::Platform.windows?
configValues = YAML::load_file("config.yml")

ENV["VAGRANT_DEFAULT_PROVIDER"] = ENV.has_key?("VAGRANT_CI") && ENV["VAGRANT_CI"].include?("lxc") ? "lxc" : "virtualbox"

if isWindows
  # Help Vagrant to detect Cygwin.
  # https://github.com/mitchellh/vagrant/blob/master/lib/vagrant/util/platform.rb#L14
  ENV["VAGRANT_DETECTED_OS"] = "cygwin"
  # Prevent closing connection.
  # https://github.com/ansible/ansible/issues/6363#issuecomment-49349902
  ENV["ANSIBLE_SSH_ARGS"] = "-o ControlMaster=no"
end

if not Vagrant.has_plugin?("vagrant-hostsupdater")
  system "vagrant plugin install vagrant-hostsupdater"
end

# Automatically load custom provisioners.
Dir["provisioners/*"].each do |file|
  file += "/#{File.basename(file)}.rb"

  if File.exist?(file)
    require_relative file
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Use the box, depending on Vagrant provider.
  config.vm.box_url = "#{configValues["vm"][ENV["VAGRANT_DEFAULT_PROVIDER"]]["box"]}"
  # Automatically name the box.
  config.vm.box = File.basename(config.vm.box_url)
  # Hosts Updated plugin insert this value to "hosts".
  config.vm.hostname = "#{configValues["project"]}.dev"
  # Handle port collisions.
  config.vm.usable_port_range = (10200..10500)

  config.vm.post_up_message = "Documentation: https://github.com/BR0kEN-/cibox

 ██████╗ ██╗     ██████╗   ██████╗  ██╗  ██╗
██╔════╝ ██║     ██╔══██╗ ██╔═══██╗ ╚██╗██╔╝
██║      ██║     ██████╔╝ ██║   ██║  ╚███╔╝
██║      ██║     ██╔══██╗ ██║   ██║  ██╔██╗
╚██████╗ ██║     ██████╔╝ ╚██████╔╝ ██╔╝ ██╗
 ╚═════╝ ╚═╝     ╚═════╝   ╚═════╝  ╚═╝  ╚═╝
"

  config.vm.provider :virtualbox do |vb|
    configValues["vm"]["virtualbox"]["modifyvm"].each do |key, value|
      vb.customize ["modifyvm", :id, "--#{key}", "#{value}"]
    end
  end

  config.vm.network :private_network,
    :ip => "#{configValues["vm"]["ip"]}",
    :lxc__bridge_name => "lxcbr0"

  configValues["vm"]["forwarded_port"].each do |port|
    if port["guest"] != "" && port["host"] != ""
      config.vm.network :forwarded_port,
        :host => port["host"].to_i,
        :guest => port["guest"].to_i,
        :auto_correct => true
    end
  end

  for folder in configValues["vm"]["synced_folder"];
    config.vm.synced_folder folder["source"], folder["target"],
      :id => folder["target"],
      # Windows (https://github.com/coreos/coreos-vagrant/issues/185#issuecomment-145260933):
      # - VBoxSF cannot be used due to "Text file busy" error (https://github.com/ansible/ansible/issues/9526#issue-48225420).
      # - NFS cannot be used due to "Device or resource busy - directory may be a mount point?" error.
      :type => isWindows ? "rsync" : "nfs",
      :rsync__args => ["--verbose", "--archive", "--delete", "-z", "--chmod=ugo=rwX"],
      :rsync__exclude => folder["excluded_paths"],
      :linux__nfs_options => ["rw", "no_subtree_check", "no_root_squash", "async"]
  end

  config.vm.provision :cibox,
    :controller => "./cibox",
    :playbook => "provisioning/provision"

  if ENV["REINSTALL"]
    config.vm.provision :shell,
      :inline => "cibox reinstall"
  end

  # Create Selenium hub.
  config.vm.provision :shell,
    :inline => "cibox tests",
    :run => "always"

  # Create Selenium node.
  config.vm.provision :cibox,
    :controller => "./selenium.sh",
    :playbook => "#{configValues["selenium"]}",
    :run => "always"

  config.ssh.shell = "sh"
  config.ssh.insert_key = false
  config.ssh.forward_agent = true
end
