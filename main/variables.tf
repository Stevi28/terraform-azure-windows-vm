variable "vm_nsg_rules" {
    type = list(object({
        name        = string
        priority    = number
        port        = list(string)
        source      = string
        destination = string
    }))
    default = [
        { name = "AllowBastiontoVM", priority = 100, port = ["3389", "22"], source = "10.1.2.0/26", destination = "10.1.1.0/24" }
    ]
}

variable "bastion_inbound_nsg_rules" {
    type = list(object({
        name     = string
        priority = number
        port     = string
        source   = string
    }))
    default = [
        { name = "AllowtoInternet", priority = 100, port = "443", source = "Internet" },
        { name = "AllowtoGatewayManager", priority = 110, port = "443", source = "GatewayManager" },
        { name = "AllowtoLoadBalancer", priority = 120, port = "443", source = "AzureLoadBalancer" }
    ]
}

variable "bastion_outbound_nsg_rules" {
    type = list(object({
        name        = string
        priority    = number
        port        = list(string)
        destination = string
    }))
    default = [
        { name = "AllowRDPSSH", priority = 130, port = ["3389", "22"], destination = "VirtualNetwork" },
        { name = "AllowAzureCloud", priority = 140, port = ["443"], destination = "AzureCloud" },
        { name = "AllowSessionInfo", priority = 150, port = ["80"], destination = "Internet" }
    ]
}

variable "admin_password" {
    description = "The password for the Windows VM admin user"
    type        = string
    sensitive   = true # hides the value from Terraform logs
}