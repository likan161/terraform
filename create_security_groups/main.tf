#____login____________________________________________________________________#
provider "openstack" {
  user_name        = "USER"
  tenant_name      = "PROJECT_NAME"
  password         = "PASSWORD"
  auth_url         = "https://auth.pscloud.io/v3/"
  region           = "RegionOne"
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
