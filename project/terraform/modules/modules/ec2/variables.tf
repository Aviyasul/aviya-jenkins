variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t3.medium"  
}

variable "subnet_id" {
  description = "The public subnet ID where the EC2 instance will be launched"
  type        = string
  default     = "subnet-0b9ba22db170eef35"
}

variable "vpc_id" {
  description = "The ID of the existing VPC to deploy the EC2 instance into"
  type        = string
  default     = "vpc-0e2aff3cba7811bf7"
}

variable "my_ip" {
  description = "Your public IP address to allow SSH access"
  type        = string
  default     = "172.31.0.0/16" 
}
