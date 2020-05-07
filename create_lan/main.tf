#_____connect_______________________________________________________________#
provider "openstack" {
  user_name            = "USER"
  tenant_name          = "PROJECT_NAME"
  password             = "PASSWORD"
  auth_url             = "https://auth.pscloud.io/v3/"
  region               = "RegionOne"
}

#__create_network________________________________________________________________________#
resource "openstack_networking_network_v2" "teraform_network" {
  name                 = "network_01"
}

#_____create_subnet______________________________________________________________________#
resource "openstack_networking_subnet_v2" "teraform_subnet" {
  name                 = "subnet_01"
  network_id           = openstack_networking_network_v2.teraform_network.id
  cidr                 = "192.168.0.0/24"
  ip_version           = 4
  enable_dhcp          = true
  dns_nameservers      = [
   "195.210.46.195",
   "195.210.46.132"
                     ]
}

#_____create_router______________________________________________________________________#
resource "openstack_networking_router_v2" "teraform_router" {
  name                = "ex-router"
  external_network_id = "83554642-6df5-4c7a-bf55-21bc74496109" #FloatingIP Net ID
}

#_____Adds_a_subnet_interface_to_the_router_____________________________________________#
resource "openstack_networking_router_interface_v2" "teraform_router_interface" {
  router_id           = openstack_networking_router_v2.teraform_router.id
  subnet_id           = openstack_networking_subnet_v2.teraform_subnet.id
}
