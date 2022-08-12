variable "prefix" {
  description = "packer-project1"
  default     = "UdacityProject1"
}

variable "location" {
  description = "West Europe"
  type        = string
  default     = "westeurope"
}

variable "vm_count" {
  description = "Number of Virtual Machines"
  default = 2
}


variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default = {
      CreatedByMe = "Nosa"
   }
}

variable "admin_username" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "nosa"
}
