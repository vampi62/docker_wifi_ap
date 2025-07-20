# build-ci.hcl
#
# only used for Github actions workflow.
# For locally building images use build.hcl
#
# For more information on buildx bake file definition see:
# https://github.com/docker/buildx/blob/master/docs/bake-reference.md
# https://github.com/docker/buildx/blob/master/docs/reference/buildx_bake.md
#
# NOTE: You can only run this from the root folder.
#-----------------------------------------------------------------------------------------
# (Environment) input variables
# If the env var is not set, then the default value is used
#-----------------------------------------------------------------------------------------
variable "REPO" {
  default = "vampi62/light-wifi-ap"
}
variable "VERSION" {
  default = "local"
}

#-----------------------------------------------------------------------------------------
# Grouping of targets to build. All these images are built when using:
# docker buildx bake -f tests\build.hcl
#-----------------------------------------------------------------------------------------
group "default" {
  targets = [
    "with-dhcp",
    "without-dhcp"
  ]
}

#-----------------------------------------------------------------------------------------
# Default settings that will be inherited by all targets (images to build).
#-----------------------------------------------------------------------------------------
target "defaults" {
  platforms = [ "linux/amd64"]
  dockerfile = "Dockerfile"
  labels = {
    "org.opencontainers.image.source" = "https://github.com/${REPO}"
    "org.opencontainers.image.description" = "Light Wifi AP ${VERSION}"
    "org.opencontainers.image.version" = "${VERSION}"
  }
}

#-----------------------------------------------------------------------------------------
# User defined functions
#------------------------------------------------------------------------------------------
# Derive all tags
function "tag" {
  params = [image_name]
  result = [
    "ghcr.io/${REPO}/${image_name}:${VERSION}",
    "ghcr.io/${REPO}/${image_name}:latest"
  ]
}

#-----------------------------------------------------------------------------------------
# All individual targets (images to build)
# Build an individual target using.
# docker buildx bake -f tests\build.hcl <target>
# E.g. to build target without-dhcp
# docker buildx bake -f tests\build.hcl without-dhcp
#-----------------------------------------------------------------------------------------

target "with-dhcp" {
  inherits = ["defaults"]
  context = "withDHCP/"
  tags = tag("with-dhcp")
}

target "without-dhcp" {
  inherits = ["defaults"]
  context = "withoutDHCP/"
  tags = tag("without-dhcp")
}
