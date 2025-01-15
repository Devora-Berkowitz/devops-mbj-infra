# Configure the Google Cloud provider
provider "google" {
  credentials = file("${path.module}/service-account-keys.json")
  project     = var.project_id
  region      = var.region
}

# Create a Google Compute Instance Template
resource "google_compute_instance_template" "mig_template" {
  name         = "${lower(replace(var.instance_name, "[^a-z0-9-]", ""))}-template"  # Ensure name is valid
  machine_type = var.machine_type

  disk {  # Change from boot_disk to disk
    auto_delete  = true
    source_image = "projects/debian-cloud/global/images/family/debian-12"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = file("${path.module}/startup.sh")

  tags = ["health-check"]  # Add a tag for health check access
}

resource "google_compute_instance_group_manager" "mig" {
  name                = "${lower(replace(var.instance_name, "[^a-z0-9-]", ""))}-mig"
  base_instance_name  = var.instance_name
  zone                = var.zone  # Changed to use var.zone
  target_size         = 2

  version {
    instance_template = google_compute_instance_template.mig_template.self_link
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.mig_health.self_link
    initial_delay_sec = 300
  }
}

# Create a Health Check for the MIG
resource "google_compute_health_check" "mig_health" {
  name = "${lower(replace(var.instance_name, "[^a-z0-9-]", ""))}-health-check"

  http_health_check {
    port = 80
  }
}

# Create an Autoscaler for the MIG
resource "google_compute_autoscaler" "mig_autoscaler" {
  name   = "${lower(replace(var.instance_name, "[^a-z0-9-]", ""))}-autoscaler"
  zone   = var.zone  # Changed to use var.zone
  target = google_compute_instance_group_manager.mig.self_link

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}

# Create a Firewall Rule to allow Health Check only on port 80
resource "google_compute_firewall" "health_check_allow" {
  name    = "allow-health-check"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]  # Allow HTTP traffic on port 80 for health check
  }

  direction = "INGRESS"
  priority  = 1000
  target_tags = ["health-check"]  # Apply rule only to instances with "health-check" tag

  source_ranges = [
    "130.211.0.0/22",  # Google Cloud Health Check IP range
    "35.191.0.0/16"
  ]
}
