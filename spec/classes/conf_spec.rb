require 'spec_helper'

describe 'freeradius::conf' do

  context 'rhel_6' do
    let(:facts) {{
      :lsbmajdistrelease => '6',
      :hardwaremodel     => 'x86_64',
      :grub_version      => '2',
      :uid_min           => '1000',
      :operatingsystem   => 'RedHat',
      :radius_version    => '2.1.0'
    }}

    it { should compile.with_all_deps }
    it { should create_class('freeradius::2::conf') }
    it { should create_file('/var/log/radius').with_ensure('directory') }
    it { should create_file('/etc/raddb/radiusd.conf').with_content(/raddbdir/) }
  end

  context 'rhel_7' do
    let(:facts) {{
      :operatingsystem   => 'RedHat',
      :lsbmajdistrelease => '7',
      :hardwaremodel     => 'x86_64',
      :grub_version      => '2',
      :uid_min           => '1000',
      :radius_version    => '3.0.1'
    }}

    it { should compile.with_all_deps }
    it { should create_class('freeradius::3::conf') }
    it { should create_file('/var/log/radius').with_ensure('directory') }
    it { should create_file('/etc/raddb/radiusd.conf').with_content(/raddbdir/) }
  end
end
