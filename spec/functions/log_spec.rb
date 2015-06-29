require 'spec_helper'

describe 'validate_freeradius_destination' do
  it { should run.with_params('stdout').and_return(nil) }
  it { should run.with_params('stdin').and_raise_error(Puppet::ParseError) }
end
