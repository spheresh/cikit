module VagrantPlugins::CIKit
  class Provisioner < Vagrant.plugin("2", :provisioner)
    def provision
      result = Vagrant::Util::Subprocess.execute(
        "bash",
        "-c",
        "#{config.controller} #{config.playbook} #{cikit_args}",
        :workdir => @machine.env.root_path.to_s,
        :notify => [:stdout, :stderr],
        :env => environment_variables,
      ) do |io_name, data|
        @machine.env.ui.info(data, {
          :new_line => false,
          :prefix => false,
          :color => io_name == :stderr ? :red : :green,
        })
      end

      if !result.exit_code.zero?
        raise Vagrant::Errors::VagrantError.new(), "CIKit provisioner responded with a non-zero exit status."
      end
    end

    protected

    def environment_variables
      environment_variables = {}
      environment_variables["ANSIBLE_INVENTORY"] = ansible_inventory
      environment_variables["ANSIBLE_SSH_ARGS"] = ansible_ssh_args
      environment_variables["ANSIBLE_ARGS"] = ENV["ANSIBLE_ARGS"]
      environment_variables["PATH"] = ENV["VAGRANT_OLD_ENV_PATH"]

      return environment_variables
    end

    def ansible_ssh_args
      ansible_ssh_args = []
      ansible_ssh_args << "-o ForwardAgent=yes" if @machine.ssh_info[:forward_agent]
      ansible_ssh_args << "-o StrictHostKeyChecking=no"
      ansible_ssh_args << ENV["ANSIBLE_SSH_ARGS"]

      return ansible_ssh_args.join(" ")
    end

    def cikit_args
      args = []
      # Append the host being provisioned.
      args << "--limit=#{@machine.name}"

      playbook = config.playbook.chomp(File.extname(config.playbook)) + ".yml"

      if File.exist?(playbook)
        taglist = []
        extra_vars = {}
        playbook = YAML::load_file(playbook)

        parse_env_vars("ANSIBLE_ARGS").each do |var, value|
          if "tags" == var
            taglist = value.split(",")
            break
          end
        end

        parse_env_vars("EXTRA_VARS").each do |var, value|
          if !value.nil?
            extra_vars[var.tr("-", "_")] = value
          end
        end

        if playbook[0].include?("vars_prompt")
          for var_prompt in playbook[0]["vars_prompt"];
            default_value = var_prompt["default"] ? var_prompt["default"].to_s : ""

            # Use default value if condition intended for not Vagrant or script
            # was run with tags and current prompt have one of them.
            if (taglist.any? && (var_prompt["tags"] & taglist).none?) || "not vagrant" == var_prompt["when"]
              value = default_value
            else
              puts var_prompt["prompt"] + (default_value.empty? ? "" : " [#{default_value}]") + ":"

              # Preselected value in environment variable.
              if extra_vars.has_key?(var_prompt["name"])
                value = extra_vars[var_prompt["name"]]
                # Show preselected value to the user.
                puts value
              else
                value = $stdin.gets.chomp
                value = value.empty? ? default_value : value
              end
            end

            args << "--#{var_prompt["name"]}=#{value}"
          end
        end
      end

      return args.join(" ")
    end

    # Auto-generate "safe" inventory file based on Vagrantfile.
    def ansible_inventory
      inventory_content = ["# Generated by CIKit"]

      # By default, in Cygwin, user's home directory is "/home/<USERNAME>" and it is not the same
      # that "C:\Users\<USERNAME>". All used software (Ansible (~/.ansible), Vagrant (~/.vagrant.d),
      # Virtualbox (~/.VirtualBox), SSH (~/.ssh)) uses correct for Windows path and this breaks a
      # lot of Linux commands (chmod - one of them and we need to use to set correct permissions to
      # SSH private key).
      if Vagrant::Util::Platform.cygwin?
        ENV["HOME"] = Vagrant::Util::Subprocess.execute("cygpath", "-wH").stdout.chomp.gsub("\\", "/") + "/" + Etc.getlogin()
      end

      @machine.env.active_machines.each do |active_machine|
        begin
          m = @machine.env.machine(*active_machine)

          if !m.ssh_info.nil?
            inventory_item = []
            inventory_item << "#{m.name} ansible_host=#{m.ssh_info[:host]}"
            inventory_item << "ansible_port=#{m.ssh_info[:port]}"
            inventory_item << "ansible_user=#{m.ssh_info[:username]}"

            if m.ssh_info[:private_key_path].any?
              inventory_item << "ansible_ssh_private_key_file=#{m.ssh_info[:private_key_path][0].gsub(ENV["HOME"], "~")}"
            else
              inventory_item << "ansible_password=#{m.ssh_info[:password]}"
            end

            inventory_content << inventory_item.join(" ")
          else
            @logger.error("Auto-generated inventory: Impossible to get SSH information for machine '#{m.name} (#{m.provider_name})'. This machine should be recreated.")
            # Let a note about this missing machine
            inventory_content << "# MISSING: '#{m.name}' machine was probably removed without using Vagrant. This machine should be recreated."
          end
        rescue Vagrant::Errors::MachineNotFound => e
          @logger.info("Auto-generated inventory: Skip machine '#{active_machine[0]} (#{active_machine[1]})', which is not configured for this Vagrant environment.")
        end
      end

      inventory_dir = Pathname.new(File.join(@machine.env.local_data_path.join, %w(provisioners cikit ansible)))
      FileUtils.mkdir_p(inventory_dir) unless File.directory?(inventory_dir)
      inventory_file = Pathname.new(File.join(inventory_dir, "inventory"))
      inventory_content = inventory_content.join("\n")

      Mutex.new.synchronize do
        if !File.exists?(inventory_file) || inventory_content != File.read(inventory_file)
          inventory_file.open("w") do |file|
            file.write(inventory_content)
          end
        end
      end

      return inventory_file
    end

    def parse_env_vars(env_var)
      vars = {}

      ENV.has_key?(env_var) && ENV[env_var].scan(/--?([^=\s]+)(?:=(\S+))?/).each do |pair|
        key, value = pair

        # Trim quotes if string starts and ends by the same character.
        if !value.nil? && ((value.start_with?('"') && value.end_with?('"')) || (value.start_with?("'") && value.end_with?("'")))
          value = value[1...-1]
        end

        vars[key] = value
      end

      return vars
    end

  end
end
