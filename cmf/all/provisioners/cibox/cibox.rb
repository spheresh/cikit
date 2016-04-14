module VagrantPlugins
  module CIBox
    class Plugin < Vagrant.plugin("2")
      name "cibox"

      config :cibox, :provisioner do
        require_relative "config"
        Config
      end

      provisioner :cibox do
        require_relative "provisioner"
        Provisioner
      end
    end
  end
end
