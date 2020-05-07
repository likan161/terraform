variable "disk_name" {
default = "test_name1"
}

variable "image_id" {
default = "22e935a1-dffe-43d5-939f-98b5a2c92771"
}

variable "disk_size" {
default = "25" #GB
}

variable "disk_type" {
default = "ceph-ssd" #type: ceph-backup, ceph-ssd, ceph-hdd
}
