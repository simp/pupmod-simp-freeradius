module Puppet::Parser::Functions
  newfunction(:validate_freeradius_destination) do |args|

    destination = args[0]

    t_valid_destinations = [
      "files",
      "syslog",
      "stdout",
      "stderr"
    ]

    unless t_valid_destinations.include?(destination)
      raise Puppet::ParseError.new("'destination' must be one of '#{t_valid_destinations.join(',')}'")
    end

  end
end
