require 'spec_helper'

describe 'freeradius::v3::conf::user', type: :define do
  context 'supported operating systems' do
    on_supported_os.each_value do |facts|
      let(:facts) { facts }
      let(:precondition) { "include 'freeradius'" }

      context 'add a user fragment' do
        let(:title) { 'test_add_user' }
        let(:params) do
          {
            content: 'test user stuff',
         confdir: '/etc/raddb'
          }
        end

        it {
          is_expected.to contain_concat__fragment('radius_user_100.test_add_user').with({
                                                                                          #          'content' => 'test_add_user test user stuff',
                                                                                          'target' => '/etc/raddb/mods-config/files/authorize'
                                                                                        })
        }
      end
      context 'add a default user fragment' do
        let(:title) { 'user999' }
        let(:params) do
          {
            content: 'default stuff',
         confdir: '/etc/raddb',
         is_default: true
          }
        end

        it {
          is_expected.to contain_concat__fragment('radius_user_100.user999').with({
                                                                                    'target' => '/etc/raddb/mods-config/files/authorize',
          'content' => 'DEFAULT default stuff'
                                                                                  })
        }
      end
    end
  end
end
