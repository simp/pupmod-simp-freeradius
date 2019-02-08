require 'spec_helper'

describe 'freeradius::v3::module', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:pre_condition) {"include  'freeradius'"}

      context 'with default parameters' do
        let(:title) {'test_module'}
        let(:params) {{
          :source => '/tmp/mymodule'
        }}

        it { is_expected.to create_file('/etc/raddb/mods-available/test_module').with({
          'source'  => '/tmp/mymodule'
        })}
        it { is_expected.to_not create_file('/etc/raddb/mods-enabled/test_module')}
      end
      context 'with enable set' do
        let(:title) {'test_module'}
        let(:params) {{
          :content => 'My module',
          :enabled => true
        }}

        it { is_expected.to create_file('/etc/raddb/mods-available/test_module').with_content(/My module/)}
        it { is_expected.to create_file('/etc/raddb/mods-enabled/test_module').with({
          'ensure'  => 'link',
          'target'  => '/etc/raddb/mods-available/test_module'
        })}
      end
      context 'with content and source set ' do
        let(:title) {'test_module'}
        let(:params) {{
          :content => 'My module',
          :source  => '/var/stuff'
        }}

        it { is_expected.to raise_error(Puppet::Error, /Only one of \$content and \$source can be specified/) }
      end

    end
  end
end

