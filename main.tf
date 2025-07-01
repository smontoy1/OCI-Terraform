# modules/network/main.tf
provider "oci" {
  # Authentication is picked up from your OCI CLI config (~/.oci/config)
  # or environment variables (OCI_CONFIG_FILE, OCI_CONFIG_PROFILE, etc.)
  # You can also explicitly set:
  #   tenancy_ocid     = var.tenancy_ocid
  #   user_ocid        = var.user_ocid
  #   fingerprint      = var.fingerprint
  #   private_key_path = var.private_key_path
  #   region           = var.region
}

resource "oci_core_virtual_network" "Montoyavcn" {
  compartment_id = var.compartment_id
  dns_label      = "Montoyavcn"
  cidr_block     = var.vcn_cidr
  display_name   = "${var.prefix}-vcn"
}

resource "oci_core_subnet" "public" {
  compartment_id      = var.compartment_id
  vcn_id              = oci_core_virtual_network.vcn.id
  cidr_block          = var.public_cidr
  display_name        = "${var.prefix}-subnet-public"
  route_table_id      = oci_core_route_table.public.id
  security_list_ids   = [oci_core_security_list.public.id]
}

resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id
  display_name   = "${var.prefix}-igw"
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_virtual_network.vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.igw.id
  }
}

# Add NAT, DRG, FastConnect, LB, DNS, etc., in similar fashion,
# each resource referencing the IDs of its dependencies above.

variable "create_instance" {
   default = true
}

resource "oci_core_instance" "WebInterface" {
   count = var.create_instance ? 1 : 0
   display_name = "WebInterfaceInstance"
   compartment_id = var.compartment_id
}

resource "oci_core_instance" "webserver" {
   count = 2
   display_name = "Webserver-${count.index}"
   compartment_id = var.compartment_id
}

variable "instances" {
   default = { "web1" = "AD-1" "web2" = "AD-2" }
}

resource "oci_core_instance" "example" {
   for_each = var.instances
   display_name = each.key
   availability_domain = each.value
   compartment_id = var.compartment_id
}
