name "sensu-gem"
default_version "0.23.1"

source git: "https://github.com/sensu/sensu.git"

version "release/0.27" do
  source git: "https://github.com/sensu/sensu.git"
end

dependency "ruby"
dependency "rubygems"
dependency "libffi"
dependency "eventmachine"
dependency "winsw" if windows?

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['CC'] = 'gcc'
  env['CXX'] = "g++ -m64"
  env['cppflags'] = "-std=c99"

  patch_env = env.dup

  files_dir = "#{project.files_path}/#{name}"

  command("gem build sensu.gemspec")

  gem("install sensu-0.26.1.gem --bindir '#{install_dir}/embedded/bin' --no-ri --no-rdoc", env: env)

  #gem "install sensu" \
  #    " --version '#{version}'" \
  #    " --bindir '#{install_dir}/embedded/bin'" \
  #    " --no-ri --no-rdoc", env: env

  gem "install sensu-plugin" \
      " --version '1.2.0'" \
      " --no-ri --no-rdoc", env: env

  gem "install sensu-plugin" \
      " --version '1.3.0'" \
      " --no-ri --no-rdoc", env: env

  embedded_dir = File.join(install_dir, "embedded")
  share_dir = File.join(embedded_dir, "share", "sensu")
  bin_dir = File.join(install_dir, "bin")
  embedded_bin_dir = File.join(embedded_dir, "bin")
  gems_dir = File.join(embedded_dir, "lib", "ruby", "gems", "*", "gems")

  # make directories
  mkdir("#{install_dir}/bin")
  mkdir("#{share_dir}/etc/sensu")
  mkdir("#{share_dir}/etc/rc.d")
  mkdir("#{share_dir}/lib/svc/manifest/site")

  # config.json.example
  copy("#{files_dir}/config.json.example", "#{share_dir}/etc/sensu")

  # sensu-install
  if windows?
    copy("#{files_dir}/sensu-install.bat", bin_dir)
  else
    copy("#{files_dir}/sensu-install", bin_dir)
    command("chmod +x #{bin_dir}/sensu-install")
  end

  # sensu rc script
  copy("#{files_dir}/sensu-client", "#{share_dir}/etc/rc.d")
  command("chmod +x #{share_dir}/etc/rc.d/sensu-client")

  # sensu manifest (solaris)
  copy("#{files_dir}/sensu-client.xml", "#{share_dir}/lib/svc/manifest/site")

  # make symlinks
  if windows?
    copy("#{files_dir}/sensu-client-windows.xml", "#{bin_dir}/sensu-client.xml")
    copy("#{files_dir}/sensu-client.exe.config", "#{bin_dir}/sensu-client.exe.config")
    move("#{bin_dir}/winsw.exe", "#{bin_dir}/sensu-client.exe")
  else
    link("#{embedded_bin_dir}/sensu-client", "#{bin_dir}/sensu-client")
    link("#{embedded_bin_dir}/sensu-server", "#{bin_dir}/sensu-server")
    link("#{embedded_bin_dir}/sensu-api", "#{bin_dir}/sensu-api")
  end
end
