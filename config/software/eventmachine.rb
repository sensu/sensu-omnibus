name "eventmachine"

dependency "ruby"
dependency "ruby-windows-devkit" if windows?

source git: "https://github.com/portertech/eventmachine.git"

default_version "master"

version "master" do
  source git: "https://github.com/eventmachine/eventmachine.git"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)
  patch_env = env.dup

  if aix?
    patch_env["PATH"] = "/opt/freeware/bin/:#{patch_env['ENV']}"
  end

  # these are needed to get eventmachine to compile on Solaris
  # but eventmachine segfaults at runtime :(
  #env['CXX'] = "g++ -m64"
  #env['cppflags'] = "-D_XOPEN_SOURCE=700"

  command "gem install rake-compiler", env: env
  command "rake clean", env: env

  # disable C++ extensions so we don't need to compile them on platforms
  # we're only using pure_ruby with
  if aix? || solaris?
    patch source: "disable-extensions.patch", plevel: 1, env: patch_env
  else
    command "rake compile", env: env
  end

  command "rake gem", env: env

  command "gem install pkg/eventmachine-1.2.0.1.gem", env: env
end
