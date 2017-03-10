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
homepage "https://sensu.io"
license "MIT"
description "A monitoring framework that aims to be simple, malleable, and scalable."

if windows?
  maintainer "Sensu, Inc."
else
  maintainer "support@sensu.io"
end

vendor = "Sensu <support@sensu.io>"

# Defaults to C:/opt/sensu on Windows
# and /opt/sensu on all other platforms
if windows?
  install_dir "#{default_root}/opt/#{name}"
else
  install_dir "#{default_root}/#{name}"
end

version = ENV["SENSU_VERSION"]
build_version version
build_iteration ENV["BUILD_NUMBER"]

override "sensu-gem", version: version
override "ruby", version: "2.3.0"
override "rubygems", version: "2.6.6"

package :deb do
  section "Monitoring"
  vendor vendor
end

gpg_passphrase = begin
                   ::File.read('/home/omnibus/.gpg_passphrase')
                 rescue => e
                   puts "Failed to load gpg_passphrase: #{e}"
                   nil
                 end

platform_version = ohai["platform_version"]

package :rpm do
  category "Monitoring"
  vendor vendor
  if Gem::Version.new(platform_version) >= Gem::Version.new(6)
    signing_passphrase gpg_passphrase
  end
end


package :msi do
  upgrade_code "29B5AA66-46B3-4676-8D67-2F3FB31CC549"
  wix_light_extension "WixNetFxExtension"
end

proj_to_work_around_cleanroom = self
package :pkg do
  identifier "io.sensu.pkg.#{proj_to_work_around_cleanroom.name}"
  #signing_identity "Developer ID Installer: Sensu, Inc. (IDHERE)"
end
compress :dmg

# TODO: config files are removed during actions such as dpkg --purge
#if linux?
#  config_file "/etc/sensu/config.json.example"
#  config_file "/etc/sensu/conf.d/README.md"
#  config_file "/etc/logrotate.d/sensu"
#  config_file "/etc/default/sensu"
#end

# Creates required build directories
dependency "preparation"

# package scripts erb templates
dependency "package-scripts" unless windows?

# sensu dependencies/components
dependency "sensu-gem"

# Version manifest file
dependency "version-manifest"

exclude "**/.git"
exclude "**/bundler/git"

# Our package scripts are generated from .erb files,
# so we will grab them from an excluded folder
package_scripts_path "#{install_dir}/.package_util/package-scripts"
exclude '.package_util'
