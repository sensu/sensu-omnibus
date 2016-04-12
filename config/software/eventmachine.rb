name "eventmachine"

dependency "ruby"

source git: "https://github.com/amdprophet/eventmachine.git"

default_version "solaris_fixes"

version "solaris_fixes" do
  source git: "https://github.com/amdprophet/eventmachine.git"
end

build do
  env = with_standard_compiler_flags(with_embedded_path)

  env['CXX'] = "g++ -m64"
  env['cppflags'] = "-D_XOPEN_SOURCE=700"

  command "gem install rake-compiler", env: env

  command "rake clean", env: env
  command "rake compile", env: env
  command "rake gem", env: env

  command "gem install pkg/eventmachine-1.2.0.1.gem", env: env
end
