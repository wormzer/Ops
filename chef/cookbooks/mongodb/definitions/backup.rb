define :generate_raid_backups do
  if ENV['AWS_SECRET_ACCESS_KEY']
    aws_creds = { "aws_access_key_id" => ENV['AWS_ACCESS_KEY'], "aws_secret_access_key" => ENV['AWS_SECRET_ACCESS_KEY'] }
  else
    aws_creds = Chef::EncryptedDataBagItem.load("passwords", node[:backups][:aws_passwords])
  end

#  volumes = node[:backups][:mongo_volumes].join(" ")

  template "/usr/local/bin/raid_snapshot.sh" do
    source "raid_snapshot.sh.erb"
    owner "root"
    group "root"
    mode "0755"
    variables("seckey" => aws_creds["aws_secret_access_key"],
              "awskey" => aws_creds["aws_access_key_id"],
              "snapshot_tags" => node[:backups][:snapshot_tags].collect { |k,v| "#{k}=#{v}" }.join(' ') )
  end
end

