module Puppet::Parser::Functions
  newfunction(:validate_freeradius_max_request_time) do |args|

    max_request_time = args[0]

    unless max_request_time.to_i.between?(2,120)
      raise Puppet::ParseError.new("max_request_time must be between 5 and 120")
    end

  end
end
