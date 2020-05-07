#_____connect_________________________________________________________________#
provider "openstack" {
  user_name   = "USER"
  tenant_name = "PROJECT_NAME"
  password    = "PASSWORD"
  auth_url    = "https://auth.pscloud.io/v3/"
  region      = "RegionOne"
}

#____import_ssh_key___________________________________________________________#
resource "openstack_compute_keypair_v2" "ssh" {
  name        = "terraform"
  public_key  = file("~/.ssh/id_rsa.pub")
}
