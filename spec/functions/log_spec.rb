require 'spec_helper'

describe 'validate_freeradius_destination' do
  it { is_expected.to run.with_params('stdout').and_return(nil) }
  it { is_expected.to run.with_params('stdin').and_raise_error(Puppet::ParseError, "\'destination\' must be one of \'files,syslog,stdout,stderr\'") }
end
