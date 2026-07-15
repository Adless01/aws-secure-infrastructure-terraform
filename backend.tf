terraform {
  backend "s3" {
    bucket = "adam-combatsec-tfstate"
    key    = "combatsec/dev/terraform.tfstate"
    region = "eu-central-1"
  }
}
