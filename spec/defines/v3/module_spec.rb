require 'spec_helper'

describe 'freeradius::v3::module', type: :define do
  context 'supported operating systems' do
    on_supported_os.each_value do |facts|
      let(:facts) { facts }
      let(:pre_condition) { "include  'freeradius'" }

      context 'with default parameters' do
        let(:title) { 'test_module' }
        let(:params) do
          {
            source: '/tmp/mymodule'
          }
        end

        it {
          is_expected.to create_file('/etc/raddb/mods-available/test_module').with({
                                                                                     'source' => '/tmp/mymodule'
                                                                                   })
        }
        it { is_expected.not_to create_file('/etc/raddb/mods-enabled/test_module') }
      end
      context 'with enable set' do
        let(:title) { 'test_module' }
        let(:params) do
          {
            content: 'My module',
         enabled: true
          }
        end

        it { is_expected.to create_file('/etc/raddb/mods-available/test_module').with_content(%r{My module}) }
        it {
          is_expected.to create_file('/etc/raddb/mods-enabled/test_module').with({
                                                                                   'ensure' => 'link',
          'target' => '/etc/raddb/mods-available/test_module'
                                                                                 })
        }
      end
      context 'with content and source set ' do
        let(:title) { 'test_module' }
        let(:params) do
          {
            content: 'My module',
         source: '/var/stuff'
          }
        end

        it { is_expected.to raise_error(Puppet::Error, %r{Only one of \$content and \$source can be specified}) }
      end
    end
  end
end
