terraform {
  backend "s3" {
    bucket = "webapp-ecs-tfstate-theresa"
    region = "ap-southeast-2"
    key = "terraform.tfstate"
  }
}
