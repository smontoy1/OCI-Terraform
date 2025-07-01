output "vcn_id" {
  description = "OCID of the VCN"
  value       = oci_core_virtual_network.vcn.id
}

output "public_subnet_id" {
  description = "OCID of the public subnet"
  value       = oci_core_subnet.public.id
}

output "private_subnet_id" {
  description = "OCID of the private subnet"
  value       = oci_core_subnet.private.id
}

output "BastionServer_PublicIP" {
  value = [data.oci_core_vnic.BastionServer_VNIC1.public_ip_address]
}

output "Webserver_Private_IPs_Formatted" {
  value =  { for i, ip in
data.oci_core_vnic.Webserver_VNIC1[*].private_ip_address :
oci_core_instance.Webserver[i].display_name => ip }
}

output "LoadBalancer_Public_IP" {
  value =
oci_load_balancer.Load.Balancer.ip_address_details[0].ip_address
}


