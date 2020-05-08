resource "openstack_lb_loadbalancer_v2" "http_balancer" {
  name          = "http_balancer"
  vip_subnet_id = "9b3dbc6a-d821-4f9e-9c19-1f6142054808" ##ID subnet
}

resource "openstack_lb_listener_v2" "http_listen" {
  name            = "http_listen"
  description     = "what to listen?"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.http_balancer.id
}

resource "openstack_lb_pool_v2" "http_pool" {
  name        = "http_pool"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.http_listen.id
}

resource "openstack_lb_monitor_v2" "http_monitor" {
  name = "http_monitor"
  delay = 5
  max_retries = 3
  timeout = 5
  type = "HTTP"
  url_path = "/"
  http_method = "GET"
  expected_codes = "200"
  pool_id = openstack_lb_pool_v2.http_pool.id
}

resource "openstack_lb_member_v2" "alpha_http_member" {
  name          = "alpha_http_member"
  address       = "192.168.0.232"
  protocol_port = 80
  pool_id       = openstack_lb_pool_v2.http_pool.id
  subnet_id     = "9b3dbc6a-d821-4f9e-9c19-1f6142054808" #ID subnet
}

#resource "openstack_lb_member_v2" "beta_http_member" {
#  name          = "beta_http_member"
#  address       = "192.168.0.232"
#  protocol_port = 80
#  weight        = 10
#  pool_id       = openstack_lb_pool_v2.http_pool.id
#  subnet_id     = openstack_networking_subnet_v2.private_subnet.id
#}

output "http_balancer_vip_address" {
  value = openstack_lb_loadbalancer_v2.http_balancer.vip_address
}
