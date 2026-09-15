group "default" {
  targets = ["push"]
}

target "metadata" {
  labels = {
    "org.opencontainers.image.authors"    = "${GITHUB_REPOSITORY_OWNER}"
    "org.opencontainers.image.created"    = "${DATE}"
    "org.opencontainers.image.os.name"    = "ubuntu"
    "org.opencontainers.image.os.version" = "${UBUNTU_VERSION}"
    "org.opencontainers.image.ref.name"   = "${GITHUB_REF_NAME}"
    "org.opencontainers.image.revision"   = "${GITHUB_SHA}"
    "org.opencontainers.image.source"     = "${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
    "org.opencontainers.image.title"      = "${IMAGE_NAME}"
    "org.opencontainers.image.url"        = "${IMAGE_REGISTRY}/${IMAGE_NAMESPACE}/${IMAGE_NAME}"
    "org.opencontainers.image.version"    = "${EDIRECT_VERSION}"
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

variable "DATE" {}

variable "GITHUB_REF_NAME" {}

variable "GITHUB_REPOSITORY" {}

variable "GITHUB_REPOSITORY_OWNER" {}

variable "GITHUB_SERVER_URL" {}

variable "GITHUB_SHA" {}

variable "IMAGE_NAME" {}

variable "IMAGE_NAMESPACE" {}

variable "IMAGE_REGISTRY" {}

variable "UBUNTU_VERSION" {}
