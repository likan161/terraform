#_____connect_______________________________________________________________#
provider "openstack" {
  user_name        = "USER"
  tenant_name      = "PROJECT_NAME"
  password         = "PASSWORD"
  auth_url         = "https://auth.pscloud.io/v3/"
  region           = "RegionOne"
}

#_____create_disk_______________________________________________________________#
resource "openstack_blockstorage_volume_v2" "disk" {
  name             = "ssd_disk"
  volume_type      = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
  size             = "20" #GB
  image_id = "22e935a1-dffe-43d5-939f-98b5a2c92771" #OC ID Centos 7
                                                   }
