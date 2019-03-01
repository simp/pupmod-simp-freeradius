require 'spec_helper'

describe 'freeradius::v3::site', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }
      let(:pre_condition) {"include  'freeradius'"}

      context 'with default parameters' do
        let(:title) {'test_site'}
        let(:params) {{
          :source => '/tmp/mysite'
        }}

        it { is_expected.to create_file('/etc/raddb/sites-available/test_site').with({
          'source'  => '/tmp/mysite'
        })}
        it { is_expected.to_not create_file('/etc/raddb/sites-enabled/test_site')}
      end
      context 'with enable set' do
        let(:title) {'test_site'}
        let(:params) {{
          :content => 'My site',
          :enabled => true
        }}

        it { is_expected.to create_file('/etc/raddb/sites-available/test_site').with_content(/My site/)}
        it { is_expected.to create_file('/etc/raddb/sites-enabled/test_site').with({
          'ensure'  => 'link',
          'target'  => '/etc/raddb/sites-available/test_site'
        })}
      end
      context 'with content and source set ' do
        let(:title) {'test_site'}
        let(:params) {{
          :content => 'My site',
          :source  => '/var/stuff'
        }}

        it { is_expected.to raise_error(Puppet::Error, /Only one of \$content and \$source can be specified/) }
      end

    end
  end
end

