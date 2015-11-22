module VagrantPlugins::CIBox
  class Config < Vagrant.plugin("2", :config)
    attr_accessor :playbook
    attr_accessor :controller

    def validate(machine)
      errors = _detected_errors

      unless controller
        errors << ':cibox provisioner requires :controller to be set.'
      end

      unless playbook
        errors << ':cibox provisioner requires :playbook to be set.'
      end

      {'CIBox Provisioner' => errors}
    end
  end
end
