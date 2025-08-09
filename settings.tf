resource "null_resource" "update_zed_settings" {
  triggers = {
    ssh_connections = jsonencode([
      for container in docker_container.project : {
        host     = "localhost"
        username = "nonroot"
        port     = container.ports[0].external
        args     = ["-i", "${abspath(path.module)}/private_key.pem"]
        projects = [{ paths = ["/home/nonroot/project"] }]
      }
    ])
  }

  provisioner "local-exec" {
    command = <<-EOT
      SETTINGS_FILE="$HOME/.config/zed/settings.json"
      mkdir -p "$(dirname "$SETTINGS_FILE")"

      if [ -f "$SETTINGS_FILE" ]; then
        EXISTING=$(cat "$SETTINGS_FILE")
      else
        EXISTING='{}'
      fi

      SSH_CONNECTIONS='${self.triggers.ssh_connections}'

      echo "$EXISTING" | jq --argjson ssh_connections "$SSH_CONNECTIONS" '. + {ssh_connections: $ssh_connections}' > "$SETTINGS_FILE"
    EOT
  }
}
