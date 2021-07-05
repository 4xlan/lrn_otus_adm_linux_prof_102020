# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :inetRouter => {
        :box_name => "centos/7",
        :route_path => "files/routes/inetRouter/",
        :net => [
                   {ip: '192.168.255.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net", ifname: "eth1"},
                ]
  },
  :centralRouter => {
        :box_name => "centos/7",
        :gateway => "192.168.255.1",
        :route_path => "files/routes/centralRouter/",
        :net => [
                   {ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
                   {ip: '192.168.0.1', adapter: 3, netmask: "255.255.255.240", virtualbox__intnet: "dir-net", ifname: "eth2"},
                   {ip: '192.168.0.33', adapter: 4, netmask: "255.255.255.240", virtualbox__intnet: "hw-net", ifname: "eth3"},
                   {ip: '192.168.0.65', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "mgt-net", ifname: "eth4"},
                ]
  },
  
  :centralServer => {
        :box_name => "centos/7",
        :gateway => "192.168.0.1",
        :net => [
                   {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
                ]
  },
  :office1Router => {
        :box_name => "centos/7",
        :gateway => "192.168.0.33",
        :net => [
                   {ip: '192.168.0.34', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
                   {ip: '192.168.2.1', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "dev1-net"},
                   {ip: '192.168.2.65', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "qa1-net"},
                   {ip: '192.168.2.129', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "mng1-net"},
                   {ip: '192.168.2.193', adapter: 6, netmask: "255.255.255.192", virtualbox__intnet: "o1hw-net"},
                ]
  },
  :office2Router => {
        :box_name => "centos/7",
        :gateway => "192.168.0.33",
        :net => [
                   {ip: '192.168.0.35', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
                   {ip: '192.168.1.129', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "qa2-net"},
                   {ip: '192.168.1.193', adapter: 4, netmask: "255.255.255.192", virtualbox__intnet: "o2hw-net"},
                ]
  },
  :office1Server => {
        :box_name => "centos/7",
        :gateway => "192.168.2.193",
        :net => [
                   {ip: '192.168.2.194', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "o1hw-net"},
                ]
  },
  :office2Server => {
        :box_name => "centos/7",
        :gateway => "192.168.1.193",
        :net => [
                   {ip: '192.168.1.194', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "o2hw-net"},
                ]
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
          if ipconf.size > 4 then # has_key? doesn't work, don't know why.
            box.vm.provision "file", source: "#{boxconfig[:route_path]}#{ipconf[:ifname]}", destination: "/tmp/route-#{ipconf[:ifname]}"
            box.vm.provision "shell", run: "always", inline: "mv /tmp/route-#{ipconf[:ifname]} /etc/sysconfig/network-scripts/"
            box.vm.provision "file", source: "files/route_crutch.sh", destination: "/tmp/route_crutch.sh"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
              systemctl restart network
              /tmp/route_crutch.sh
            SHELL
          end
        end

        box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh; cp ~vagrant/.ssh/auth* ~root/.ssh
            sed -i '65s/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
            systemctl restart sshd
        SHELL
        
        if boxname.to_s.include? "Router"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "net.ipv4.conf.all.forwarding = 1" > /etc/sysctl.d/99-sysctl.conf
            sysctl -p
            SHELL
        end
        
        if boxname.to_s == "inetRouter" then
            box.vm.provision "shell", run: "always", inline: <<-SHELL
            iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
            systemctl restart network
            SHELL
        else
            box.vm.provision "file", source: "files/network_crutch.sh", destination: "/tmp/network_crutch.sh"
            box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
            echo -e "GATEWAY=#{boxconfig[:gateway]}\nDEFROUTE=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth1 
            systemctl restart network
            /tmp/network_crutch.sh
            SHELL
        end
    end
  end
end
