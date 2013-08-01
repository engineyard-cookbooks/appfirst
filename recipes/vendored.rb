package_file_name = "appfirst-x86_64.deb"

cookbook_file "#{Chef::Config[:file_cache_path]}/#{package_file_name}" do
  source package_file_name
  owner 'root'
  group 'root'
  mode '644'
end

dpkg_package 'appfirst' do
  source "#{Chef::Config[:file_cache_path]}/#{package_file_name}"
end

link "/opt/appfirst" do
  to "/opt/AppFirst"
  ignore_failure true
end

template "/etc/appfirst.tags" do
  source "appfirst.tags.erb"
  mode 0644
  owner "root"
  group "root"
  variables({
    :tags => node[:appfirst][:tags]
  })
end

# workaround
execute "remove bogus appfirst sources" do
  command 'sed -i -E "s/^(deb|deb-src) http:\/\/frontend.appfirst.com/#\1 http:\/\/frontend.appfirst.com/" /etc/apt/sources.list'
  only_if '/bin/grep -q -E "^(deb|deb-src) http:\/\/frontend.appfirst.com" /etc/apt/sources.list'
end

service "afcollector" do
  supports :restart => true, :start => true
  action [:enable, :start]
end
