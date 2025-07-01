# 1) Fetch your tenancy OCID
data "oci_identity_tenancy" "tenant" {}

# 2) Look up the compartment by its display name
data "oci_identity_compartments" "target" {
  compartment_id = data.oci_identity_tenancy.tenant.id
  display_name   = var.compartment_name
}

locals {
  compartment_id = data.oci_identity_compartments.target.compartments[0].id
}

# 3) Create the VCN
resource "oci_core_virtual_network" "vcn" {
  compartment_id = local.compartment_id
  cidr_block     = var.vcn_cidr
  display_name   = var.vcn_name
  dns_label      = var.dns_label
}

# 4) Public Subnet
resource "oci_core_subnet" "public" {
  compartment_id     = local.compartment_id
  virtual_network_id = oci_core_virtual_network.vcn.id
  cidr_block         = var.public_subnet_cidr
  display_name       = "${var.vcn_name}-public"
  dns_label          = "${var.dns_label}-pub"
}

# 5) Private Subnet
resource "oci_core_subnet" "private" {
  compartment_id     = local.compartment_id
  virtual_network_id = oci_core_virtual_network.vcn.id
  cidr_block         = var.private_subnet_cidr
  display_name       = "${var.vcn_name}-private"
  dns_label          = "${var.dns_label}-priv"
}

