terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
  }
}

variable "projects" {
  type        = map(object({}))
  description = "Map of project configurations"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "workspace" {
  name = "workspace"

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "image/workspace/*") : filesha1(f)]))
  }

  build {
    tag        = ["workspace:latest"]
    context    = "image/workspace"
    dockerfile = "image/workspace/Dockerfile"
    build_args = {
      SSH_PUBKEY = tls_private_key.ssh_key.public_key_openssh
    }
  }
}

resource "docker_network" "project_network" {
  for_each = var.projects
  name     = "project-${each.key}"
  internal = true
}

resource "docker_network" "proxy_network" {
  name = "proxy-network"
}

resource "docker_volume" "project_shared" {
  name = "project-shared"
}

resource "docker_volume" "project" {
  for_each = var.projects
  name     = "project-${each.key}"
}

resource "docker_container" "project" {
  for_each = var.projects
  image    = docker_image.workspace.image_id
  name     = "project-${each.key}"
  hostname = each.key

  log_opts = {
    max-file = "5"
    max-size = "20m"
  }

  networks_advanced {
    name = docker_network.project_network[each.key].name
  }

  volumes {
    volume_name    = docker_volume.project_shared.name
    container_path = "/shared"
  }

  volumes {
    volume_name    = docker_volume.project[each.key].name
    container_path = "/home/nonroot/project"
  }

  labels {
    label = "workspace"
    value = each.key
  }

  ports {
    internal = 22
  }
}
