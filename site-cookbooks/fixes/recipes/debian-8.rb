#
# Cookbook Name:: fixes
# Recipe:: debian-8
#
# Copyright (c) 2020 Sensu, All Rights Reserved.

execute "ls /etc/apt/" do
  compile_time true
  action :run
end

execute "cat /etc/apt/sources.list" do
  compile_time true
  action :run
end

execute "ls /etc/apt/sources.list.d" do
  compile_time true
  action :run
end

execute "cat /etc/apt/sources.list.d/*" do
  compile_time true
  action :run
end
