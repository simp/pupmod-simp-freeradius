module Puppet::Parser::Functions
  newfunction(:validate_freeradius_max_requests) do |args|

    max_requests = args[0]

    unless ( max_requests.to_i > 256 )
      raise Puppet::ParseError.new("max_requests must be greater than 256")
    end

  end
end
