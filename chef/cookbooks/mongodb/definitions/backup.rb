define :generate_raid_backups do
  if ENV['AWS_SECRET_ACCESS_KEY']
    aws_creds = { "aws_access_key_id" => ENV['AWS_ACCESS_KEY'], "aws_secret_access_key" => ENV['AWS_SECRET_ACCESS_KEY'] }
  else
    aws_creds = Chef::EncryptedDataBagItem.load("passwords", node[:backups][:aws_passwords])
  end

  %q{hourly daily}.each do |period|
    template "/usr/local/bin/#{period}_snapshot.sh" do
      source "#{period}_snapshot.sh.erb"
      owner "root"
      group "root"
      mode "0755"
      variables("seckey" => aws_creds["aws_secret_access_key"],
                "awskey" => aws_creds["aws_access_key_id"],
                "snapshot_tags" => node[:backups][:snapshot_tags].collect { |k,v| "#{k}=#{v}" }.join(' ') )
    end
  end

  cron "hourly_snapshot" do
    command = "bash /usr/local/bin/hourly_snapshot.sh"
    minute "0"
    hour "02-22/2"
  end

  cron "daily_snapshot" do
    command "bash /usr/local/bin/daily_snapshot.sh"
    minute "0"
    hour "0"
  end
end
