sensu Omnibus project
=====================
This project creates full-stack platform-specific packages for
`sensu`!

Preparing Build Environments
----------------------------

### AIX 6.x/7.x (powerpc)

**NOTE: Ensure the date is correctly set before following any of the AIX guides.**

#### Requesting an AIX instance

**NOTE: Caleb's IBM id is the only account that currently can spin up instances**

1. Sign into the Power Development Cloud website
(https://www-356.ibm.com/partnerworld/wps/ent/pdp/web/MyProgramAccess).

2. Select `Virtual Server Access` from the `Please select a program` dropdown.

3. Enter a project name of `sensu-client`.

4. Enter a project description of `sensu-client build box`.

5. Select `Existing customer support` from `Project opportunity`.

6. Select `Build and test` from `Project classification`.

7. Ensure the start date is at least two hours from the current time. This is
unfortunately the least amount of time needed for AIX instance requests. The
actual time that it takes for the instance to spin up can sometimes be less
than two hours.

8. Ensure the end date is long enough for builds/tests to be run.

9. Select `IBM AIX 6.1` from `Select an image`.

10. Unless you will be building a new Saved Image, select `Saved image` from
`Select an image type` and `aix-6_1-with-xl-deps` from `Select an image`.

11. Click `Add Resources to project`.

12. Click `Create project and reservation`.

#### Building a new Saved Image

1. SSH into the AIX instance as root and run the following commands:

  ```sh
  chfs -a size=+7G /
  chfs -a size=+3G /opt
  chfs -a size=+3G /usr
  chfs -a size=+3G /var
  ```

2. Download the AIX 6.1 ISO and mount it:

  ```sh
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "https://s3-us-west-2.amazonaws.com/sensuapp.org/build-dependencies/AIX_6100-09-07_Install_1_of_2_052016.iso" > aix.iso
  mkdir /cdrom
  loopmount -i aix.iso -o "-V cdrfs -o ro" -m /cdrom
  ```

3. Install the prerequesites needed for IBM XL C/C++:

  ```sh
  installp -acXgd /cdrom bos.adt.include
  installp -acXgd /cdrom bos.adt.lib
  installp -acXgd /cdrom bos.adt.libm
  installp -acXgd /cdrom bos.rte
  installp -acXgd /cdrom bos.rte.libc
  installp -acXgd /cdrom bos.loc.utf.EN_US
  ```

4. Create the Saved Image by right-clicking the reservation ID on the IBM PDP
website and click `Save image`.

#### Installing the XL C/C++ compiler trial for AIX

1. Make a new directory to store the IBM XL C/C++ installation files:

  ```sh
  mkdir /ibmxl_install
  cd /ibmxl_install
  ```

2. Download the IBM XL C/C++ trial:

  ```sh
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "https://s3-us-west-2.amazonaws.com/sensuapp.org/build-dependencies/IBM_XL_C_CPP_V13.1.3.0_AIX_EVAL.tar.Z" > "ibm_xl.tar.Z"
  ```

3. Uncompress and extract IBM XL C/C++:

  ```sh
  zcat ibm_xl.tar.Z | tar -xvf -
  ```

4. Install IBM XL C/C++:

  ```sh
  installp -aXYgd usr/sys/inst.images all
  ```

#### Preparing the AIX instance for builds

1. Remove any gcc packages that may cause issues later on:

  ```sh
  rpm -e libstdc++ libstdc++-devel libgcc gcc-c++ gcc gcc-locale
  ```

2. Remove `pkg-config` because it interferes with the Ruby build:

  ```sh
  rpm -e pkg-config
  ```

3. Install the base tools:

  ```sh
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/wget/wget-1.9.1-3.aix6.1.ppc.rpm
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/sudo/sudo-1.8.15-1noldap.aix6.1.ppc.rpm
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/bash/bash-4.3.30-1.aix6.1.ppc.rpm
  ```

4. Install zlib:

  ```sh
  rpm -U ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/zlib/zlib-1.2.8-1.aix6.1.ppc.rpm
  rpm -U ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/zlib/zlib-devel-1.2.8-1.aix6.1.ppc.rpm
  ```

5. Install GNU tar:

  ```sh
  rpm -U ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/tar/tar-1.22-1.aix6.1.ppc.rpm
  ```

6. Change limits:

  ```sh
  chsec -f /etc/security/limits -s default -a "data=-1"
  chsec -f /etc/security/limits -s default -a "rss=-1"
  chsec -f /etc/security/limits -s default -a "nofiles=50000"
  ```

7. Set the PATH environment variable in in `/.bash_profile`:

  ```sh
  echo 'export PATH=/opt/IBM/xlC/13.1.3/bin:/opt/IBM/xlc/13.1.3/bin:/usr/bin:/etc:/usr/sbin:/usr/local/bin:/opt/freeware/bin:/usr/ucb:/sbin:/usr/lpp/X11/bin:' >> ~/.bash_profile
  ```

8. Allow `bash` as a shell and make `bash` the default shell:

  ```sh
  echo '/usr/bin/bash' >> /etc/shells
  chsec -f /etc/security/login.cfg -s usw -a "shells=/bin/sh,/bin/bsh,/bin/csh,/bin/ksh,/bin/tsh,/bin/ksh93,/usr/bin/sh,/usr/bin/bsh,/usr/bin/csh,/usr/bin/ksh,/usr/bin/tsh,/usr/bin/ksh93,/usr/bin/rksh,/usr/bin/rksh93,/usr/sbin/uucp/uucico,/usr/sbin/sliplogin,/usr/sbin/snappd,/usr/bin/bash"
  chsh root /usr/bin/bash
  exit
  ```

9. After reconnecting to SSH, install `make` and `coreutils`:

  ```sh
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/make/make-3.81-1.aix6.1.ppc.rpm
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/coreutils/coreutils-5.2.1-2.aix5.1.ppc.rpm
  ```

10. Install a newer version of `wget`:

  ```sh
  wget http://ftp.gnu.org/gnu/wget/wget-1.15.tar.gz
  gtar xzf wget-1.15.tar.gz
  cd wget-1.15
  CC=xlc_r ./configure --with-ssl=openssl --enable-largefile
  CC=xlc_r make
  CC=xlc_r make install
  rpm -e wget
  cd ..
  source ~/.bash_profile
  ```

11. Install the latest version of `openssl`:

  ```sh
  wget --no-check-certificate https://www.openssl.org/source/openssl-1.0.1t.tar.gz
  gtar xf openssl-1.0.1t.tar.gz
  cd openssl-1.0.1t
  OBJECT_MODE=32 ./Configure aix-cc shared
  OBJECT_MODE=32 make depend
  OBJECT_MODE=32 make
  slibclean
  OBJECT_MODE=32 make install
  cd ..
  ```

12. Install the default cacert bundle:

  ```sh
  wget --no-check-certificate -O /usr/local/ssl/certs/cacert.pem http://curl.haxx.se/ca/cacert.pem
  ```

13. Install a newer version of `curl` and link it against `openssl`:

  ```sh
  wget --no-check-certificate https://curl.haxx.se/download/curl-7.49.1.tar.gz
  gtar xf curl-7.49.1.tar.gz
  cd curl-7.49.1
  ./configure --with-ssl=/usr/local/ssl --with-ca-bundle=/usr/local/ssl/certs/cacert.pem
  make
  make install
  cd ..
  ```

14. Install `sed` and `expat`:

  ```sh
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/sed/sed-4.1.1-1.aix5.1.ppc.rpm
  rpm -U ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/expat/expat-2.0.1-2.aix5.3.ppc.rpm
  rpm -U ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/expat/expat-devel-2.0.1-2.aix5.3.ppc.rpm
  ```

15. Install `m4` and `autoconf`:

  ```sh
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/m4/m4-1.4.13-1.aix6.1.ppc.rpm
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/autoconf/autoconf-2.69-1.aix6.1.noarch.rpm
  ```

16. Install `git`:

  ```sh
  wget --no-check-certificate -O git.tar.gz https://github.com/git/git/archive/v2.8.3.tar.gz
  gtar xf git.tar.gz
  cd git-2.8.3
  autoconf
  ./configure --with-curl=/usr/local --without-tcltk
  sed -e 's#va_copy#aix_va_copy#' strbuf.c > strbuf.c.bak && mv strbuf.c.bak strbuf.c
  sed -e 's#define va_copy#define aix_va_copy#' git-compat-util.h > git-compat-util.h.bak && mv git-compat-util.h.bak git-compat-util.h
  sed -e 's#^INSTALL = install#INSTALL = /opt/freeware/bin/install#' Makefile > Makefile.bak && mv Makefile.bak Makefile
  gmake
  gmake install
  cd ..
  git config --global user.email "justin@heavywater.io"
  git config --global user.name "Justin Kolberg"
  ```

17. Install `patch`:

  ```sh
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/patch/patch-2.5.4-4.aix4.3.ppc.rpm
  ```

18. Install `libffi`:

  ```sh
  wget ftp://sourceware.org/pub/libffi/libffi-3.1.tar.gz
  gtar xf libffi-3.1.tar.gz
  cd libffi-3.1
  INSTALL=/opt/freeware/bin/install ./configure
  gmake
  gmake install
  cd ..
  ```

19. Install `ruby`:

  ```sh
  wget --no-check-certificate https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
  gtar xf ruby-2.3.1.tar.gz
  cd ruby-2.3.1
  LDFLAGS="-L/usr/local/lib" CFLAGS="-qlanglvl=extc99 -I/usr/local/include -I/usr/local/lib/libffi-3.1/include" ./configure --disable-install-rdoc
  make
  make install
  cd ..
  ```

20. Install `bundler`:

  ```sh
  gem install bundler --no-ri --no-rdoc
  ```

21. Install `awk`:

  ```sh
  rpm -i ftp://ftp.software.ibm.com/aix/freeSoftware/aixtoolbox/RPMS/ppc/gawk/gawk-3.1.3-1.aix5.1.ppc.rpm
  ```

#### Preparing the AIX instance for builds with Chef (WIP/BROKEN)

1. Download Chef:

  ```sh
  perl -e 'use LWP::Simple; getprint($ARGV[0]);' "https://packages.chef.io/stable/aix/6.1/chef-12.10.24-1.powerpc.bff" > chef-12.10.24-1.powerpc.bff
  ```

2. Install Chef:

  ```sh
  installp -aXYgd chef-12.10.24-1.powerpc.bff all
  ```

3. Create the Chef cookbook directory:

  ```sh
  mkdir /var/chef/cookbooks
  ```

4. Run `vi download.rb` and paste the following contents:

  ```ruby
  %w(https://supermarket.chef.io/cookbooks/aix/download
     https://supermarket.chef.io/cookbooks/aix-base-setup/download
  ).each do |cb|
    remote_file 'download cookbook' do
      source cb
      path '/var/chef/cookbooks/cookbook.tar.gz'
      notifies :run, 'execute[extract-cookbook]', :immediately
    end

    execute 'extract-cookbook' do
      cwd '/var/chef/cookbooks/'
      command 'gzip -d < /var/chef/cookbooks/cookbook.tar.gz | tar xvf -'
      action :nothing
    end
  end
  ```

5. Apply the `download.rb` recipe with `chef-apply`:

  ```sh
  chef-apply download.rb
  ```

6. Run `vi /var/chef/solo.json` and paste the following:

  ```json
  {
    "run_list":[
      "recipe[aix-base-setup]"
    ]
  }
  ```

7. Run `vi /var/chef/solo.rb` and paste the following:

  ```ruby
  root = File.absolute_path(File.dirname(__FILE__))
  node_name "localhost"
  file_cache_path root
  cookbook_path [ root + '/cookbooks', root + '/site-cookbooks' ]
  ```

8. Change to the `/var/chef` directory and run `chef-solo`:

  ```sh
  cd /var/chef && chef-solo -c solo.rb -j solo.json
  ```

9. Add `zsh` to `/etc/shells` and :

  ```sh
  echo '/usr/bin/zsh' >> /etc/shells
  chsec -f /etc/security/login.cfg -s usw -a "shells=/bin/sh,/bin/bsh,/bin/csh,/bin/ksh,/bin/tsh,/bin/ksh93,/usr/bin/sh,/usr/bin/bsh,/usr/bin/csh,/usr/bin/ksh,/usr/bin/tsh,/usr/bin/ksh93,/usr/bin/rksh,/usr/bin/rksh93,/usr/sbin/uucp/uucico,/usr/sbin/sliplogin,/usr/sbin/snappd,/usr/bin/zsh"
  ```

10. Change root's shell to `zsh` and then reconnect:

  ```sh
  chsh root /usr/bin/zsh
  exit
  ```

### Solaris 10 (x86/sparc)

1. Add the following lines to the end of `/etc/profile`, and then reconnect via SSH:

  ```sh
  PATH=/opt/csw/bin:$PATH:/usr/ccs/bin:/usr/sfw/bin:/usr/openwin/bin:/usr/local/bin
  TERM=xterm
  export PATH
  export TERM
  ```

2. Install the CSW repository tools:

  ```
  pkgadd -d http://get.opencsw.org/now
  pkgutil -U
  ```

3. Install dependencies via CSW:

  ```
  pkgutil -y -i ruby20 ruby20_dev curl git gcc5core emacs_nox libffi6 libffi_dev
  ```

4. Patch Ruby's rbconfig.rb to use gcc:

  * x86   - `/opt/csw/lib/ruby/2.0.0/i386-solaris2.10/rbconfig.rb`
  * sparc - `/opt/csw/lib/ruby/2.0.0/sparc-solaris2.10/rbconfig.rb`

  ```
  Change "-KPIC" to "-fPIC"
  Set CC to "/opt/csw/bin/gcc-5.2"
  Change "-xO3" to "-O3"
  Remove "-xarch=sparc" (sparc-only)
  Change "-xarch=" to "-march=" (x86-only)
  Add "-I/opt/csw/lib/libffi-3.2.1/include" to CPPFLAGS
  ```

5. Install rake & bundler:

  ```
  gem install rake bundler --no-rdoc --no-ri
  ```

6. Clone the omnibus-sensu directory:

  ```
  git clone git@github.com:sensu/omnibus-sensu.git
  ```

7. Configure git:

  ```
  git config --global user.email "justin@heavywater.io"
  git config --global user.name "Justin Kolberg"
  ```

### Windows (x86/x86_64)

1. Install Ruby (latest 2.2.x as 2.3+ has a bug).

2. Install msys2 (choose arch that matches the package being built).

3. Install mingw (choose arch that matches the package being built).

4. Set PATH. Append:

  ```
  C:\msys2\mingw64\bin;C:\msys2\usr\bin;C:\Ruby22-x64\bin
  ```

5. Install git

6. Install gcc

  32-bit:

  ```
  pacman -S mingw-w64-i686-gcc
  ```

  64-bit:

  ```
  pacman -S mingw-w64-x86_64-gcc
  ```

Installation
------------
You must have a sane Ruby 1.9+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
$ bundle install --binstubs
```

Usage
-----
### Build

You create a platform-specific package using the `build project` command:

```shell
$ bin/omnibus build sensu
```

The platform/architecture type of the package created will match the platform
where the `build project` command is invoked. For example, running this command
on a MacBook Pro will generate a Mac OS X package. After the build completes
packages will be available in the `pkg/` folder.

### Clean

You can clean up all temporary files generated during the build process with
the `clean` command:

```shell
$ bin/omnibus clean sensu
```

Adding the `--purge` purge option removes __ALL__ files generated during the
build including the project install directory (`/opt/sensu`) and
the package cache directory (`/var/cache/omnibus/pkg`):

```shell
$ bin/omnibus clean sensu --purge
```

### Publish

Omnibus has a built-in mechanism for releasing to a variety of "backends", such
as Amazon S3. You must set the proper credentials in your `omnibus.rb` config
file or specify them via the command line.

```shell
$ bin/omnibus publish path/to/*.deb --backend s3
```

### Help

Full help for the Omnibus command line interface can be accessed with the
`help` command:

```shell
$ bin/omnibus help
```

Version Manifest
----------------

Git-based software definitions may specify branches as their
default_version. In this case, the exact git revision to use will be
determined at build-time unless a project override (see below) or
external version manifest is used.  To generate a version manifest use
the `omnibus manifest` command:

```
omnibus manifest PROJECT -l warn
```

This will output a JSON-formatted manifest containing the resolved
version of every software definition.


Kitchen-based Build Environment
-------------------------------
Every Omnibus project ships will a project-specific
[Berksfile](http://berkshelf.com/) that will allow you to build your omnibus projects on all of the projects listed
in the `.kitchen.yml`. You can add/remove additional platforms as needed by
changing the list found in the `.kitchen.yml` `platforms` YAML stanza.

This build environment is designed to get you up-and-running quickly. However,
there is nothing that restricts you to building on other platforms. Simply use
the [omnibus cookbook](https://github.com/opscode-cookbooks/omnibus) to setup
your desired platform and execute the build steps listed above.

The default build environment requires Test Kitchen and VirtualBox for local
development. Test Kitchen also exposes the ability to provision instances using
various cloud providers like AWS, DigitalOcean, or OpenStack. For more
information, please see the [Test Kitchen documentation](http://kitchen.ci).

Once you have tweaked your `.kitchen.yml` (or `.kitchen.local.yml`) to your
liking, you can bring up an individual build environment using the `kitchen`
command.

```shell
$ bin/kitchen converge ubuntu-1204
```

Then login to the instance and build the project as described in the Usage
section:

```shell
$ bundle exec kitchen login ubuntu-1204
[vagrant@ubuntu...] $ cd sensu
[vagrant@ubuntu...] $ bundle install
[vagrant@ubuntu...] $ ...
[vagrant@ubuntu...] $ bin/omnibus build sensu
```

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.
