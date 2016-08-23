#
# Copyright 2016 Heavy Water Operations, LLC.
#
# All Rights Reserved.
#

unless ENV.key?("SENSU_VERSION")
  puts "SENSU_VERSION must be set"
  exit 2
end

unless ENV.key?("BUILD_NUMBER")
  puts "BUILD_NUMBER must be set"
  exit 2
end

name "sensu"
maintainer "justin@heavywater.io"
homepage "https://sensuapp.org"

# Defaults to C:/opt/sensu on Windows
# and /opt/sensu on all other platforms
if windows?
  install_dir "#{default_root}/opt/#{name}"
else
  install_dir "#{default_root}/#{name}"
end

package :msi do
  upgrade_code "29B5AA66-46B3-4676-8D67-2F3FB31CC549"
end

version = ENV["SENSU_VERSION"]
build_version version
build_iteration ENV["BUILD_NUMBER"]

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
