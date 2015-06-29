module Puppet::Parser::Functions
  newfunction(:validate_cleanup_delay) do |args|

    cleanup_delay = args[0]

    if ! ( cleanup_delay.to_i > 2 && cleanup_delay.to_i < 10 ) then
      raise Puppet::ParseError.new("cleanup_delay must be between 2 and 10")
    end

  end
end
