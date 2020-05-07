#____login____________________________________________________________________#
provider "openstack" {
  user_name        = "USER"
  tenant_name      = "PROJECT_NAME"
  password         = "PASSWORD"
  auth_url         = "https://auth.pscloud.io/v3/"
  region           = "RegionOne"
}

#____import_ssh_key___________________________________________________________#
resource "openstack_compute_keypair_v2" "ssh" {
  name             = var.project_name
  public_key       = var.public_key
}

#____create_network___________________________________________________________#
resource "openstack_networking_network_v2" "private_network" {
  name             = var.project_name
}

#____create_subnet____________________________________________________________#
resource "openstack_networking_subnet_v2" "private_subnet" {
  name             = var.project_name
  network_id       = openstack_networking_network_v2.private_network.id
  cidr             = "192.168.0.0/24"
  dns_nameservers  = [
   "195.210.46.195",
   "195.210.46.132"
                     ]
  ip_version       = 4
  enable_dhcp      = true
}

#____create_router____________________________________________________________#
resource "openstack_networking_router_v2" "router" {
  name             = var.project_name
  external_network_id = "83554642-6df5-4c7a-bf55-21bc74496109" #install gateway
}

#____Adds_a_subnet_interface_to_the_router
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id        = openstack_networking_router_v2.router.id
  subnet_id        = openstack_networking_subnet_v2.private_subnet.id
}

#____allocate_ip_to_the_project_______________________________________________#
resource "openstack_networking_floatingip_v2" "instance_fip" {
  pool             = var.lan_pool
}

#_____create_securite_group___________________________________________________#
resource "openstack_compute_secgroup_v2" "security_group" {
  name             = var.project_name
  description      = "open all icmp, and ssh"
  rule {
    from_port      = 22
    to_port        = 22
    ip_protocol    = "tcp"
    cidr           = "0.0.0.0/0"
  }
  rule {
    from_port      = -1
    to_port        = -1
    ip_protocol    = "icmp"
    cidr           = "0.0.0.0/0"
  }
#  rule {
#    from_port     = -1
#    to_port       = -1
#    ip_protocol   = "tcp"
#    cidr          = "0.0.0.0/0"
#  }
}

#_____create_disk_______________________________________________________________#
resource "openstack_blockstorage_volume_v2" "disk" {
  name             = var.project_name
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = var.disk_size
  image_id         = var.image_id
                                                   }
#_____create instans___________________________________________________________#
resource "openstack_compute_instance_v2" "instance" {
  name             = var.project_name
  flavor_name      = var.flavor
  key_pair         = openstack_compute_keypair_v2.ssh.name
  security_groups  = [openstack_compute_secgroup_v2.security_group.name]

  network {
    uuid           = openstack_networking_network_v2.private_network.id
          }

  block_device {
    uuid           = openstack_blockstorage_volume_v2.disk.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
               }

#provisioner "remote-exec" {
#connection {
#user              = (var.ssh_user_name)
#key_file          = (var.ssh_key_file)
#            }
                                                    }

#_____assign floating ip_______________________________________________________
resource "openstack_compute_floatingip_associate_v2" "instance_fip_association" {
  floating_ip      = openstack_networking_floatingip_v2.instance_fip.address
  instance_id      = openstack_compute_instance_v2.instance.id
  fixed_ip         = openstack_compute_instance_v2.instance.access_ip_v4
                                                                                         }

#____access_to_instans_________________________________________________________
output "address" {
value = openstack_networking_floatingip_v2.instance_fip.address
}
output "user" {
value = var.ssh_user_name
}
output "disk sizer" {
value = var.disk_size
}
output "flavor" {
value = var.flavor
}
