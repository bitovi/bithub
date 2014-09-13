Vagrant.configure(2) do |config|
  config.vm.box = "chef/debian-7.4"

  config.vm.network "forwarded_port", guest: 80,    host: 8080   # http
  config.vm.network "forwarded_port", guest: 5432,  host: 5433   # postgres
  config.vm.network "forwarded_port", guest: 15672, host: 15673  # rabbitmq admin
  config.vm.network "forwarded_port", guest: 6379,  host: 6380   # redis

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "ansible/site.yml"
    ansible.sudo = true
    ansible.host_key_checking = false
    # ansible.verbose = "vvvv"
    # ansible.tags = ["ruby"]
    ansible.extra_vars = {
      ansible_ssh_user: "vagrant",
      vagrantvm: true
    }
  end
end
