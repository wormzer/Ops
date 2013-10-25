class Chef::ResourceDefinitionList::MongoDB
  # Returns an array of snapshot ids that represent the latest consistent 
  # snapshot of the N raided <volumes>.  Each volume's snapshot description is
  # expected to have the form "Mongo RAID Snapshot <timestamp> <disk_number>".
  # A set of snapshots are considered consistent if they share the timestamp in
  # the description.  If no such group of snapshots are found, this returns
  # nil.  The returned snapshots array will be parallel to the volumes array,
  # i.e the latest snapshot for the Nth volume in the array will be the Nth
  # snapshot in the result.
  def self.find_snapshots(key, secret_key, region, volumes, clustername)
    require 'aws-sdk'

    if volumes.size == 0
      Chef::Log.info "No reference volumes given.  Returning empty list."
      return []
    end

    # Compute the latest snapshots.
    ec2 = AWS::EC2.new(
          :access_key_id => key,
          :secret_access_key => secret_key).regions[region]

    # group our snapshots by timestamp, and while were doing this, filter out snapshots that are incomplete or for 
    # other volumes. We put all of this logic in a memoize block so each fetch of a snapshot
    # attribute will not result in a network connection.
    snapshots_by_marker = Hash.new {|h,k| h[k] = Array.new}
    AWS.memoize do
      volume_filter = []
      volumes.each { |v| volume_filter << "volume-id" << v }

      ec2.snapshots.filter(*volume_filter).filter("status", "completed").each do |s|
        snapshots_by_marker[s.tags['timestamp']] << s if s.tags['timestamp']
      end
    end

    # we find the last one that has the right number of volumes and return it
    snapshots_by_marker.keys.reverse_each do |timestamp|
      snapshots = snapshots_by_marker[timestamp]
      return snapshots.map { |s| s.id } if snapshots.size == volumes.size
    end

    return nil
  end
end
