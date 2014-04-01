#!/bin/bash
export AWS_ACCESS_KEY_ID="<%=@awskey%>"
export AWS_SECRET_ACCESS_KEY="<%=@seckey%>"

snapshot_period=hourly
keep_revisions=<%= node['backups']['keep_revisions']['hourly'] || 0 %>

/usr/local/bin/mongo-ec2-raid-snapshot \
    --quiet \
    --region <%= node['backups']['region'] %> \
    --description "Mongo RAID Snapshot (<%= node['backups']['snapshot_tags'].collect { |k,v| "#{k}=#{v}" }.join(' ') %>)" \
    --tags "<%= node['backups']['snapshot_tags'].collect { |k,v| "#{k}=#{v}" }.join(' ') %>" \
    --period $snapshot_period \
    --retain-periods $keep_revisions \
    <%= node['backups']['mongo_volumes'].join(" ") %>
