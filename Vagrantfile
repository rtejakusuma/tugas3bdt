Vagrant.configure("2") do |config|

  (1..3).each do |i|
    config.vm.define "redis#{i}" do |node|
      node.vm.hostname = "redis#{i}"
      node.vm.box = "bento/ubuntu-18.04"
      node.vm.network "private_network", ip: "192.168.16.#{11+i}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "redis#{i}"
        vb.gui = false
        vb.memory = "512"
      end

      node.vm.provision "shell", path: "sh/redis-#{i}.sh", privileged: false
    end
  end

  (1..2).each do |i|
    config.vm.define "wordpress#{i}" do |node|
      node.vm.hostname = "wordpress#{i}"
      node.vm.box = "bento/ubuntu-18.04"
      node.vm.network "private_network", ip: "192.168.16.#{14+i}"

      node.vm.provider "virtualbox" do |vb|
        vb.name = "wordpress#{i}"
        vb.gui = false
        vb.memory = "512"
      end

      node.vm.provision "shell", path: "sh/wordpress.sh", privileged: false
    end
  end

end