# Output the name of the instance template created by Terraform
output "instance_template_name" {
  description = "The name of the instance template"
  value       = google_compute_instance_template.mig_template.name
}

# Output the name of the managed instance group (MIG)
output "instance_group_manager_name" {
  description = "The name of the managed instance group"
  value       = google_compute_instance_group_manager.mig.name
}

# Output the name of the autoscaler linked to the MIG
output "autoscaler_name" {
  description = "The name of the autoscaler"
  value       = google_compute_autoscaler.mig_autoscaler.name
}