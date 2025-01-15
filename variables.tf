# Define the project ID for Google Cloud
variable "project_id" {
  description = "The ID of the GCP project"
  type        = string
}

# Define the region where resources will be deployed
variable "region" {
  description = "The region to deploy the resources"
  type        = string
  default     = "me-west1"
}

# Define the zone where resources will be deployed
variable "zone" {
  description = "The zone to deploy the resources"
  type        = string
  default     = "me-west1-b"
}

# Define the prefix for instance names
variable "instance_name" {
  description = "The name prefix for the instances"
  type        = string
}

# Define the machine type for the VM instances
variable "machine_type" {
  description = "The type of machine to use"
  type        = string
  default     = "e2-micro"
}
