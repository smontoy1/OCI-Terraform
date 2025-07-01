# variables
variable "compartment_name" {
  description = "Montoya OCI compartment"
  type        = string
  default     = "stephenmontoya"
}

variable "vcn_name" {
  description = "Name of the Virtual Cloud Network (VCN)"
  type        = string
  default     = "MontoyaVCN01"
}

variable "vcn_cidr" {
  description = "CIDR block for the VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "dns_label" {
  description = "DNS label for the VCN (lowercase, unique)"
  type        = string
  default     = "montoyavcn01"
}

variable "create_instance" {
  description = "Create an instance(lowercase, unique)"
  default     = true

variable "env" {
   default = "dev"
}

