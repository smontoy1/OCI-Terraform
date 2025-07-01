data "oci_identity_availability_domain" "AD1" {
  compartment_id = var.compartment_id
  name = "AD-1"
}

resource "oci_core_subnet" "example" {
  cidr_block = "10.0.0.0/24"
  availability_domian = data.oci_identity_availability_domain.AD1.name
}

