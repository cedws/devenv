resource "docker_network" "master" {
  name     = "master"
  internal = true
}

resource "docker_container" "project_sidecar" {
  for_each = var.projects
  image    = "nginxdemos/hello"
  name     = "project-${each.key}-sidecar"

  log_opts = {
    max-file = "5"
    max-size = "20m"
  }

  networks_advanced {
    name = docker_network.project_network[each.key].name
  }

  networks_advanced {
    name = docker_network.master.name
  }
}

resource "docker_container" "project_metadata" {
  image = "nginxdemos/hello"
  name  = "project-metadata"

  log_opts = {
    max-file = "5"
    max-size = "20m"
  }

  networks_advanced {
    name = docker_network.master.name
  }
}
