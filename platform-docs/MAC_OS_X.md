### Mac OS X / macOS

1. Download the Vagrant boxes from the `virtualbox` folder in the `sensu-omnibus-artifacts` bucket.

2. Store the Vagrant boxes in your `vagrant.d` directory so it looks
   like below:

  ```
  ➜  sensu-omnibus git:(master) ✗ cd
  ~/.vagrant.d/boxes/sensu-VAGRANTSLASH-macos-10.12/0/virtualbox
  
  ➜  virtualbox ls -l
  total 14846872
  -rw-r--r--  1 justin  staff         449  8 Mar 18:33 Vagrantfile
  -rw-r--r--  1 justin  staff        8793  8 Mar 18:33 box.ovf
  -rw-r--r--  1 justin  staff  7601574912  8 Mar 18:33
  macos-10.12-disk1.vmdk
  -rw-r--r--  1 justin  staff          26  8 Mar 18:33 metadata.json
  
  ➜  virtualbox pwd
  /Users/justin/.vagrant.d/boxes/sensu-VAGRANTSLASH-macos-10.12/0/virtualbox
  ```

3. Run the builds (first run will fail, just re-run the command):

  ```
  KITCHEN_LOCAL_YAML=.kitchen.virtualbox.yml bundle exec kitchen converge default-macos -l debug
  ```
