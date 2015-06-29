module Puppet::Parser::Functions
  newfunction(:validate_destination) do |args|

    destination = args[0]

    t_valid_destinations = [
      "files",
      "syslog",
      "stdout",
      "stderr"
    ]

    if ! t_valid_destinations.include?(destination) then
      raise Puppet::ParseError.new("'destination' must be one of '#{t_valid_destinations.join(',')}'")
    end

  end
end
