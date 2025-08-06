resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.module}/private_key.pem"
  file_permission = "0600"
}
