module Puppet::Parser::Functions
  newfunction(:validate_freeradius_cleanup_delay) do |args|

    cleanup_delay = args[0]

    unless cleanup_delay.to_i.between?(2,10)
      raise Puppet::ParseError.new("cleanup_delay must be between 2 and 10")
    end

  end
end
