Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
	v.gui = true
  end
  config.vm.box = "precise32"
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.provision :shell, :path => "bootstrap.sh"
end
