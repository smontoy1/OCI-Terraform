# OCI-Terraform
IaC for my OCI projects

Here’s how you stitch subnets, gateways, load-balancers, FastConnect, DNS zones, and SR-IOV-enabled shapes into a single, repeatable Infrastructure-as-Code workflow—using Terraform (the de facto standard for OCI IaC) as our example.

---

## 1. Core IaC Concepts

1. **Declarative state**
   You describe *what* you want (a VCN, subnets, gateways, etc.), and the provider figures out *how* to create it.
2. **Dependency graph**
   Terraform builds a graph from resource references (e.g. a subnet refers to its VCN) so it knows the correct create/delete order.
3. **Modules**
   Group related resources (e.g. all network components) into a reusable package.

---

## 2. Logical Flow & Resource Dependencies

1. **VCN & Subnets**

   * **Define a VCN** → carve into public/private subnets
   * Subnet blocks reference the VCN’s OCID, so Terraform knows it must create the VCN first

2. **Gateways & Routing**

   * **Internet/NAT/Service Gateways** are attached to the VCN
   * **DRG (Dynamic Routing Gateway)** for on-prem connectivity via FastConnect or VPN
   * **Route Tables** reference gateways (e.g. 0.0.0.0/0 → Internet Gateway) and attach to subnets

3. **Load Balancer**

   * Deployed into one or more subnets (you supply the subnet OCIDs)
   * Depends on subnet creation and on your SSL certificates and backend sets

4. **FastConnect**

   * **Cross-connects & Virtual Circuit** resources reference your DRG and your on-prem provider details
   * Terraform ensures your DRG exists before binding the virtual circuit

5. **DNS**

   * Define **DNS zones** and **records** (A, CNAME, TXT) pointing to your load balancer or compute instances
   * Your zone resource can even depend on your LB’s public IP address to populate an “A” record

6. **SR-IOV-Enabled Shapes**

   * When you declare a compute instance, choose an SR-IOV-capable shape (e.g. `BM.GPU3.8` or `E4.Flex`)
   * Assign it to one of your subnets and attach a VNIC with a specific network-security-group for micro-segmentation

---

## 3. Example Terraform Module Structure

```hcl
# modules/network/main.tf
resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_id
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
```

You’d then invoke this module with:

```hcl
module "network" {
  source         = "./modules/network"
  compartment_id = var.compartment_id
  prefix         = "prod"
  vcn_cidr       = "10.0.0.0/16"
  public_cidr    = "10.0.1.0/24"
  # …other subnet CIDRs…
}
```

---

## 4. Putting It All Together

1. **Plan & Validate**

   ```bash
   terraform init
   terraform plan   # you’ll see VCN → subnets → gateways → route tables → DRG → FastConnect → LB → DNS
   ```
2. **Apply**

   ```bash
   terraform apply
   ```
3. **Drift Detection & Iteration**

   * Use `terraform plan` regularly to catch manual changes
   * Evolve your module inputs (new subnets, upgraded shapes) without rewriting the module

---

## 5. Director-Level Best Practices

* **Versioned Modules**
  Publish your network module to an internal registry so dev/test/prod all use the same vetted code.
* **Policy-as-Code**
  Embed checks (via Terraform Cloud Sentinel or OCI Config) to enforce approved CIDR ranges, required tags, and non-public-only subnets.
* **Automated CI/CD**
  Integrate Terraform runs into your pipeline:

  * PR → `terraform plan` with drift report
  * Merge → `terraform apply` to staging, then production
* **Documentation & Blueprints**
  Maintain a living diagram and README that maps each variable to a business intent (e.g. “Public subnet = DMZ for LB front-ends”).



