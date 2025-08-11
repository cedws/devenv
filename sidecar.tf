resource "docker_network" "sidecar" {
  name = "sidecar"
}

resource "docker_image" "sidecar" {
  name = "sidecar"

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "image/sidecar/*") : filesha1(f)]))
  }

  build {
    tag        = ["sidecar:latest"]
    context    = "image/sidecar"
    dockerfile = "image/sidecar/Dockerfile"
  }
}

resource "docker_container" "sidecar" {
  for_each = var.projects
  image    = docker_image.sidecar.image_id
  name     = "project-${each.key}-sidecar"

  env = [
    "TARGET_CONTAINER=project-${each.key}",
  ]

  log_opts = {
    max-file = "5"
    max-size = "20m"
  }

  networks_advanced {
    name = docker_network.project[each.key].name
  }

  networks_advanced {
    name = docker_network.proxy.name
  }

  ports {
    internal = 22
  }
}
