#
# Copyright 2016 Heavy Water Operations, LLC.
#
# All Rights Reserved.
#

name "sensu"
maintainer "justin@heavywater.io"
homepage "https://sensuapp.org"

# Defaults to C:/sensu on Windows
# and /opt/sensu on all other platforms
install_dir "#{default_root}/#{name}"

version = "0.23.0"
build_version version
build_iteration 1

override "sensu-gem", version: version
override "ruby", version: "2.3.0"
override "rubygems", version: "2.5.2"

# Creates required build directories
dependency "preparation"

# sensu dependencies/components
dependency "sensu-gem"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"
