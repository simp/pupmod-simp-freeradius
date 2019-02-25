require 'spec_helper'

describe 'freeradius::v3::conf::instantiate' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      let(:facts) { facts }

      it { is_expected.to create_class('freeradius::v3::conf::instantiate') }

      context 'keep_defaults_false' do
        let(:params) {{
          :keep_defaults => false,
          :content       => 'test_content',
          :confdir       => '/etc/raddb',
          :group         => 'radiusd'
        }}

        it { is_expected.to create_file('/etc/raddb/conf.d/instantiate.inc').with_content(<<EOF
instantiate {
  test_content
}
EOF
        )}
      end

      context 'keep_defaults_true' do
        let(:params) {{
          :keep_defaults => true,
          :confdir       => '/etc/raddb',
          :group         => 'radiusd'
        }}

        it { is_expected.to create_file('/etc/raddb/conf.d/instantiate.inc').with_content( <<EOF
instantiate {
  exec
  expr
  expiration
  logintime
}
EOF
        )}
      end
    end
  end
end
