#### Configure the OpenStack Provider ####
provider "openstack" {
  user_name   = ""
  tenant_name = ""
  password    = ""
  auth_url    = "https://auth.pscloud.io/v3/"
                     }
#### End config block ####


#### Import SSH key ####
resource "openstack_compute_keypair_v2" "ssh" {
  name             = "keypair_name"
  public_key       = var.public_key
                                              }
#### End Import block ####


#### Create Network ####
resource "openstack_networking_network_v2" "private_network" {
  name             = "network_name"
  admin_state_up   = "true"
                                                             }
#### End Network block ####


#### Сreate subnet ####
resource "openstack_networking_subnet_v2" "private_subnet" {
  name             = "subnet_name"
  network_id       = openstack_networking_network_v2.private_network.id
  cidr             = "192.168.0.0/24"
  dns_nameservers  = [
                      "195.210.46.195",
                      "195.210.46.132"
                     ]
  ip_version       = 4
  enable_dhcp      = true
  depends_on = [openstack_networking_network_v2.private_network]
                                                           }
#### End subnet block ####


#### Create Router ####
resource "openstack_networking_router_v2" "router" {
  name             = "router_name"
  external_network_id = "83554642-6df5-4c7a-bf55-21bc74496109" #install gateway
  admin_state_up   = "true"
  depends_on = [openstack_networking_network_v2.private_network]
                                                   }
#### End router block ####


#### Adds a subnet interface to the router ####
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id        = openstack_networking_router_v2.router.id
  subnet_id        = openstack_networking_subnet_v2.private_subnet.id
  depends_on       = [openstack_networking_router_v2.router]
                                                                       }
#### End subnet interface block ####


#### Allocate ip to the project ####
resource "openstack_networking_floatingip_v2" "instance_fip" {
  pool             = var.lan_pool
                                                             }
#### End Allocate IP block ####


#### Create securite group #####
resource "openstack_compute_secgroup_v2" "security_group" {
  name             = "sg_name"
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
#### End securite group block ####


#### Create Disk ####
resource "openstack_blockstorage_volume_v3" "disk" {
  name             = "volume_name"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = var.disk_size
  image_id         = var.image_id
  enable_online_resize = "true" 
                                                   }
#### End Create disk block ####


#### Create Instans ####
resource "openstack_compute_instance_v2" "instance" {
  name             = "instance_name"
  flavor_name      = var.flavor
  key_pair         = openstack_compute_keypair_v2.ssh.name
  security_groups  = [openstack_compute_secgroup_v2.security_group.name]

  depends_on = [
                openstack_networking_network_v2.private_network,
                openstack_blockstorage_volume_v3.disk
]
  network {
    uuid           = openstack_networking_network_v2.private_network.id
          }

  block_device {
    uuid           = openstack_blockstorage_volume_v3.disk.id
    boot_index     = 0
    source_type    = "volume"
    destination_type = "volume"
    delete_on_termination = false
               }

                                                   }
#### End Create Instans block ####


#### Assign floating IP ####
resource "openstack_compute_floatingip_associate_v2" "instance_fip_association" {
  floating_ip      = openstack_networking_floatingip_v2.instance_fip.address
  instance_id      = openstack_compute_instance_v2.instance.id
  fixed_ip         = openstack_compute_instance_v2.instance.access_ip_v4
                                                                                }
#### End Assign floadting IP block ####


#### Access to Instans ####
output "address" {
value = openstack_networking_floatingip_v2.instance_fip.address
                 }
output "user" {
value = var.ssh_user_name
              }
output "disk_size" {
value = var.disk_size
                   }
output "flavor" {
value = var.flavor
                }
#### End Acces block ####
