resource "docker_image" "project_proxy" {
  name = "proxy"

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(path.module, "image/proxy/*") : filesha1(f)]))
  }

  build {
    tag        = ["proxy:latest"]
    context    = "image/proxy"
    dockerfile = "image/proxy/Dockerfile"
  }
}

resource "docker_container" "proxy" {
  image     = docker_image.project_proxy.image_id
  name      = "project-proxy"
  read_only = true

  log_opts = {
    max-file = "5"
    max-size = "20m"
  }

  networks_advanced {
    name = docker_network.proxy_network.name
  }

  dynamic "networks_advanced" {
    for_each = var.projects

    content {
      name = docker_network.project_network[networks_advanced.key].name
    }
  }
}
