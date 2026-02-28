locals {
  common_tags = {
    project = var.project
    enviornment = var.enviornment
    terraform = "true"
  }
  vpc_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.enviornment}"
    },
    var.vpc_tags
  )
}