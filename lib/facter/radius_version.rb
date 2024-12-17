#
# Return the version of FreeRADIUS installed on the system.
#
# Returns 'unknown' if the version cannot be determined.
#
Facter.add('radius_version') do
  radiusd = Facter::Core::Execution.which('radiusd')
  confine { radiusd }

  setcode do
    radius_version = 'unknown'
    begin
      Facter::Core::Execution.exec("#{radiusd} -v").to_s.split("\n").first =~ %r{.*[Vv]ersion\s((\d\.?)+)}
      radius_version = Regexp.last_match(1) unless Regexp.last_match(1).to_s.empty?
    rescue Errno::ENOENT
      # No-op because we only care that the version is unknown if we can't execute a version check.
    end
    radius_version
  end
end
