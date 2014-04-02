packages = %w{python-boto python-pymongo python-yaml}
packages.each do |p|
  package p do
    action :install
  end
end

generate_raid_backups {}

cookbook_file "/usr/local/bin/mongo-ec2-raid-snapshot" do
  source "mongo-ec2-raid-snapshot"
  owner "root"
  group "root"
  mode "0755"
end

# install backup cron on the backup node
cron "mongo_backups" do
	action :delete
end
