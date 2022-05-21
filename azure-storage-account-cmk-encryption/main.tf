data "template_file" "sa-cmk-encryption" {
  template = file("${path.module}/../../resources/external/enable-sa-cmk-encryption")

  vars = {
    kv_name     = var.kv_name
    sub_name    = var.sub_name
    key_name    = var.key_name
    key_version = var.key_version
    sa_name     = var.sa_name
    sa_rg_name  = var.sa_rg_name
  }
}

resource "null_resource" "sa-cmk-encryption" {
  triggers = {
    kv_name = var.kv_name
  }

  provisioner "local-exec" {
    command = data.template_file.sa-cmk-encryption.rendered
  }
}
