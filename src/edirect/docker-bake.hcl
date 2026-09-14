group "default" {
  targets = ["push"]
}

target "metadata" {
  labels = {
    "Description" = "NCBI EDirect"
    "Maintainer"  = "ycyant88@gmail.com"
    "Vendor"      = "NCBI/NLM/NIH"
    "Version"     = "${EDIRECT_VERSION}-ubuntu${UBUNTU_VERSION}"
  }
}

target "push" {
  inherits  = ["settings", "metadata"]
  output    = ["type=registry"]
  platforms = ["linux/amd64", "linux/arm64"]
  tags = [
    "${IMAGE_REGISTRY}/${IMAGE_NAMESPACE}/${IMAGE_NAME}:latest",
    "${IMAGE_REGISTRY}/${IMAGE_NAMESPACE}/${IMAGE_NAME}:${EDIRECT_VERSION}",
    "${IMAGE_REGISTRY}/${IMAGE_NAMESPACE}/${IMAGE_NAME}:${EDIRECT_VERSION}-ubuntu${UBUNTU_VERSION}"
  ]
}

target "test" {
  inherits  = ["settings", "metadata"]
  output    = ["type=cacheonly"]
  platforms = ["linux/amd64", "linux/arm64"]
}

target "settings" {
  args = {
    edirect_version = "${EDIRECT_VERSION}"
    ubuntu_version  = "${UBUNTU_VERSION}"
    version         = "${EDIRECT_VERSION}"
  }
  context    = "."
  dockerfile = "Dockerfile"
}

variable "EDIRECT_VERSION" {}

variable "IMAGE_NAME" {}

variable "IMAGE_NAMESPACE" {}

variable "IMAGE_REGISTRY" {}

variable "UBUNTU_VERSION" {}