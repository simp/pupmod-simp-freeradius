#
# Return the version of FreeRADIUS installed on the system.
#
# Returns 'unknown' if the version cannot be determined.
#
Facter.add("radius_version") do
  setcode do
    radiusd = Facter::Core::Execution.which('radiusd')
    confine{ radiusd }

    radius_version = 'unknown'
    begin
      %x{#{radiusd} -v}.to_s.split("\n").first =~ /.*[Vv]ersion\s((\d\.?)+)/
      radius_version = $1 if not $1.to_s.empty?
    rescue Errno::ENOENT
      #No-op because we only care that the version is unknown if we can't execute a version check.
    end
    radius_version
  end
end
