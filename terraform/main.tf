
resource "virtualbox_vm" "ubuntu" {
  name = "Ubuntuu"
  //image  = "https://app.vagrantup.com/ubuntu/boxes/noble64/versions/20240926.0.0/providers/virtualbox.box"
  image  = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  cpus   = 1
  memory = "2048 mib"

  network_adapter {
    type = "nat"
  }


}

resource "virtualbox_vm" "rocky" {
  name   = "Rocky"
  image  = "https://app.vagrantup.com/generic/boxes/rocky9/versions/4.3.12/providers/virtualbox.box"
  cpus   = 1
  memory = "2048 mib"

  network_adapter {
    type = "nat"
  }

}
