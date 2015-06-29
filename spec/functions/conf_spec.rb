require 'spec_helper'

describe 'validate_freeradius_cleanup_delay' do
  it { is_expected.to run.with_params('8').and_return(nil) }
  it { is_expected.to run.with_params('15').and_raise_error(Puppet::ParseError, "cleanup_delay must be between 2 and 10" ) }
end

describe 'validate_freeradius_max_request_time' do
  it { is_expected.to run.with_params('80').and_return(nil) }
  it { is_expected.to run.with_params('150').and_raise_error(Puppet::ParseError, "max_request_time must be between 5 and 120" ) }
end

describe 'validate_freeradius_max_requests' do
  it { is_expected.to run.with_params('512').and_return(nil) }
  it { is_expected.to run.with_params('127').and_raise_error(Puppet::ParseError, "max_requests must be greater than 256" ) }
end
