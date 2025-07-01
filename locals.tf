locals {
   subnet_cidr = "${var.base_cidr_block}/24"
   server_name = upper("webserver")
}
resource "oci_core_subnet" "montoyasubnet" {
   cidr_block = local.subnet_cidr
   display_name = local.server_name
}
locals {
   availability_domains = [ for i in range(1,3) : "AD${i}"]
}
# result: ["AD1", "AD2", "AD3"]

locals {
   instance_size = var.env == "prod" ? "VM.Standard2.4" : "VM.Standard2.1"
}


