#____import_ssh_key___________________________________________________________#
resource "openstack_compute_keypair_v2" "ssh" {
  name        = "terraform"
  public_key  = file("~/.ssh/id_rsa.pub")
}
