name "sensu-gem"
default_version "0.23.1"

dependency "ruby"
dependency "rubygems"
dependency "libffi"
dependency "eventmachine"

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['CC'] = 'gcc'
  env['CXX'] = "g++ -m64"
  env['cppflags'] = "-std=c99"

  patch_env = env.dup

  files_dir = "#{project.files_path}/#{name}"

  gem "install sensu" \
      " --version '#{version}'" \
      " --bindir '#{install_dir}/embedded/bin'" \
      " --no-ri --no-rdoc", env: env

  gem "install sensu-plugin" \
      " --version '1.2.0'" \
      " --no-ri --no-rdoc", env: env

  gem "install sensu-plugin" \
      " --version '1.4.2'" \
      " --no-ri --no-rdoc", env: env

  embedded_dir = File.join(install_dir, "embedded")
  share_dir = File.join(embedded_dir, "share", "sensu")
  bin_dir = File.join(install_dir, "bin")
  embedded_bin_dir = File.join(embedded_dir, "bin")
  gems_dir = File.join(embedded_dir, "lib", "ruby", "gems", "*", "gems")

  # delete spec directory from all sensu gems because they sometimes
  # contain symlinks which break windows and shouldn't be bundled
  # anyways
  command "rm -rf #{gems_dir}/sensu*/spec"

  # make directories
  mkdir("#{install_dir}/bin")
  mkdir("#{share_dir}/etc/sensu")
  mkdir("#{share_dir}/etc/rc.d")
  mkdir("#{share_dir}/lib/svc/manifest/site")

  # config.json.example
  copy("#{files_dir}/config.json.example", "#{share_dir}/etc/sensu")

  # sensu-install
  copy("#{files_dir}/sensu-install", bin_dir)
  command("chmod +x #{bin_dir}/sensu-install")

  # sensu rc script
  copy("#{files_dir}/sensu-client", "#{share_dir}/etc/rc.d")
  command("chmod +x #{share_dir}/etc/rc.d/sensu-client")

  # sensu manifest (solaris)
  copy("#{files_dir}/sensu-client.xml", "#{share_dir}/lib/svc/manifest/site")

  # make symlinks
  if windows?
    # TODO: add service xml file(s)
  else
    link("#{embedded_bin_dir}/sensu-client", "#{bin_dir}/sensu-client")
    link("#{embedded_bin_dir}/sensu-server", "#{bin_dir}/sensu-server")
    link("#{embedded_bin_dir}/sensu-api", "#{bin_dir}/sensu-api")
  end
end
