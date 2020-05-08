#__create_network________________________________________________________________________#
resource "openstack_networking_network_v2" "teraform_network" {
  name                 = var.lan_name
}

#_____create_subnet______________________________________________________________________#
resource "openstack_networking_subnet_v2" "teraform_subnet" {
  name                 = var.lan_name
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
  name                = var.lan_name
  external_network_id = "83554642-6df5-4c7a-bf55-21bc74496109" #FloatingIP Net ID
  depends_on = ["name"]
}

#_____Adds_a_subnet_interface_to_the_router_____________________________________________#
resource "openstack_networking_router_interface_v2" "teraform_router_interface" {
  router_id           = openstack_networking_router_v2.teraform_router.id
  subnet_id           = openstack_networking_subnet_v2.teraform_subnet.id
}
