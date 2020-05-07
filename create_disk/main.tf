#_____create_disk_______________________________________________________________#
resource "openstack_blockstorage_volume_v2" "disk" {
  name             = var.disk_name
  volume_type      = var.disk_type
  size             = var.disk_size
  image_id = var.image_id
                                                   }
