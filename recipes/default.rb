#
# Cookbook Name:: appfirst
# Recipe:: default
#
# Copyright 2012, Yipit.com
#
# All rights reserved - Do Not Redistribute
#

tmp_file_location = "/tmp/appfirst"

# Figure out our architecture
case node[:kernel][:machine]
when "x86_64"
	arch = "x86_64"
when "i386","i686"
	arch = "i386"
end

# Figure out our platform
case node['platform']
when "ubuntu","debian"
	extention = "deb"
when "centos","redhat","fedora"
	extention = "rpm"
end

service "afcollector" do
  supports :restart => true, :start => true
  action :nothing
end

dpkg_package "appfirst" do
	source "#{tmp_file_location}"
	only_if "ls #{tmp_file_location} > /dev/null"
	action :nothing
	notifies :restart, "service[afcollector]"
end

remote_file "appfirst" do
	path tmp_file_location
	source "http://wwws.appfirst.com/packages/initial/#{node.appfirst_account_id}/appfirst-#{arch}.#{extention}"
	# Don't want our run to fail if the endpoint is having temporary issues.
	ignore_failure true
	action :nothing
	notifies :install, "dpkg_package[appfirst]", :immediately
end

http_request "Check Appfirst Modified Time" do
	message ""
	url "http://wwws.appfirst.com/packages/initial/#{node.appfirst_account_id}/appfirst-#{arch}.#{extention}"
	action :head
	if File.exists?(tmp_file_location)
		headers "If-Modified-Since" => File.mtime(tmp_file_location).httpdate
	end
	notifies :create, "remote_file[appfirst]", :immediately
end





