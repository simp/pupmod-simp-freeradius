module Puppet::Parser::Functions
  newfunction(:validate_max_requests) do |args|

    max_requests = args[0]

    if ! ( max_requests.to_i > 256 ) then
      raise Puppet::ParseError.new("max_requests must be greater than 256")
    end

  end
end
