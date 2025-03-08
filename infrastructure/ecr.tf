resource "aws_ecr_repository" "my_repo" {
  name                 = "signaling-server"
  image_tag_mutability = "MUTABLE" # You can use "IMMUTABLE" if you want to prevent overwriting images
}