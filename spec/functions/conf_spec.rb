require 'spec_helper'

describe 'validate_freeradius_cleanup_delay' do
  it { should run.with_params('8').and_return(nil) }
  it { should run.with_params('15').and_raise_error(Puppet::ParseError) }
end

describe 'validate_freeradius_max_request_time' do
  it { should run.with_params('80').and_return(nil) }
  it { should run.with_params('150').and_raise_error(Puppet::ParseError) }
end

describe 'validate_freeradius_max_requests' do
  it { should run.with_params('512').and_return(nil) }
  it { should run.with_params('127').and_raise_error(Puppet::ParseError) }
end
