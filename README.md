Sensu Omnibus project
=====================
This project uses [Chef's Omnibus toolchain](https://github.com/chef/omnibus) to
create full-stack platform-specific [Sensu](https://sensuapp.org) packages.

The configuration data in this repository describes the various dependencies
which are built and included in the Sensu omnibus package. In addition to
omnibus configuration, the project also includes a Chef cookbook, Test
Kitchen and Travis CI configuration for executing individual builds in AWS EC2
compute instances.

## Supported Platforms

### Packages Built Using Automation Pipeline

Packages for Linux platforms are built automatically whenever a tag following
the format `$SENSU_VERSION-$BUILD_NUMBER` is created on this repository.

This is accomplished using Travis CI to run Test Kitchen for the following
platform and architecture combinations:

| Platform & Version | 64bit | 32bit | Comments                 |
|--------------------|-------|-------|--------------------------|
| Ubuntu 12.04       | ✅     | ✅     |                          |
| Ubuntu 14.04       | ✅     | ✅     |                          |
| Ubuntu 16.04       | ✅     | ❌     | No official 32bit images |
| Debian 7           | ✅     | ✅     |                          |
| Debian 8           | ✅     | ❌     | No official 32bit images |
| CentOS 5           | ✅     | ✅     | 32 and 64bit images built with [sensu-omnibus-packer](https://github.com/sensu/sensu-omnibus-packer) |
| CentOS 6           | ✅     | ✅     | Using unofficial 32bit image |
| CentOS 7           | ✅     | ❌     | No official 32bit images |
| FreeBSD 10         | ✅     | ❌     | Official 32bit images are out of date |
| FreeBSD 11         | ✅     | ❌     | No official 32bit images |
| Windows 2012r2     | ✅     | ❌     |                          |
| Mac OS X 10.9      | ✅     | ❌     | See [Mac platform notes](platform-docs/MAC_OS_X.md) for instructions |
| Mac OS X 10.10     | ✅     | ❌     | See [Mac platform notes](platform-docs/MAC_OS_X.md) for instructions |
| Mac OS X 10.11     | ✅     | ❌     | See [Mac platform notes](platform-docs/MAC_OS_X.md) for instructions |
| macOS 10.12        | ✅     | ❌     | See [Mac platform notes](platform-docs/MAC_OS_X.md) for instructions |

### Packages Built By Hand

Additional platform packages are built by hand on an ad hoc basis. We hope to
add these builds to the automation pipeline in the future.

| Platform & Version | Architecture | Comments                                                        |
|--------------------|--------------|-----------------------------------------------------------------|
| AIX                | PowerPC      | See [AIX platform notes](platform-docs/AIX.md) for instructions |
| Solaris 10         | i386         | See [Solaris 10](platform-docs/SOLARIS_10.md) for instructions  |
| Solaris 11         | i386         | Documentation needed                                            |

## Installation

This project requires a Ruby 1.9+ environment with Bundler installed. Ensure all
the required gems are installed:

```shell
$ bundle install --binstubs
```

## Test Kitchen Usage

The Test Kitchen `.kitchen.yml` configuration in this project defines the
list of platforms we can build using Test Kitchen + Travis CI automation.

In combination with the `sensu_omnibus` cookbook and `Berksfile` included in
this project, builds can be initiated on EC2 instances from your local
environment using the `kitchen` command, e.g.:

```shell
$ ./bin/kitchen test ubuntu-1204
```

This test will provision a new EC2 instance, install Chef and use Chef to
initiate a Sensu package build using the values of environment variables
described in the next section.

For a complete list of all commands and platforms, run `kitchen list` or
`kitchen help`.

### Test Kitchen Environment Variables

Automated builds use a Test Kitchen configuration which relies on the following
environment variables set to appropriate values:

| Environment Variable    | Description                                                     |
|-------------------------|-----------------------------------------------------------------|
| `AWS_REGION`            | Region where AWS instances will be created                      |
| `AWS_ACCESS_KEY_ID`     | Access key ID for AWS account                                   |
| `AWS_SECRET_ACCESS_KEY` | Secret access key for AWS account                               |
| `AWS_SSH_KEY_NAME`      | Name of SSH key pair (must exist in specified AWS region)       |
| `AWS_SSH_KEY_PATH`      | Local path to SSH private key matching named SSH key            |
| `SENSU_VERSION`         | Must correspond to a published Sensu gem available on RubyGems  |
| `BUILD_NUMBER`          | Denotes the incremental build number used for package artifacts |

Additionally, the following optional environment variables are used if they are set:

| Environment Variable    | Description                                                                  |
|--------------------------|------------------------------------------------------------------------------|
| `AWS_IAM_PROFILE_NAME`   | Optional IAM profile name to be associated with EC2 instances                |
| `BUILD_PLATFORM`         | Optional platform name, set by Travis CI  when creating per-platform jobs    |
| `TRAVIS_JOB_NUMBER`      | Optional job identifier, set by Travis CI. Used for tagging EC2 instances    |
| `GPG_PASSPHRASE`         | Optional passphrase for signing package artifacts; currently unused          |
| `GNUPG_PATH`             | Optional path to gpg keyring for signing package artifacts; currently unused |
| `AWS_S3_CACHE_BUCKET`    | S3 bucket containing optional build dependency cache. If unset, dependencies are downloaded directly from upstream sources. |
| `AWS_S3_ARTIFACT_BUCKET` | S3 bucket where build artifacts (packages) will be uploaded after a successful build. |

### AWS Credential Security

Automated build pipeline makes use of Travis CI encryption to secure sensitive
environment variables, as well as a copy of the ssh private key required to
access the EC2 instances this pipeline creates.

As a result, should the AWS credentials or ssh key pair for this pipeline require
rotating, the `travis` utility should be used to:

* update the secure environment variables in `.travis.yml`:

 `travis encrypt AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=... --add`

* update the ciphertext copy of ssh private key in `.travis/sensu-omnibus-artifact-builder.pem.enc`:

  `travis encrypt-file sensu-omnibus-artifact-builder.pem`
