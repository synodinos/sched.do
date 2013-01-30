require 'spec_helper'

describe UserDataFetcher, '#fetch' do
  it 'returns a user' do
    user = create(:user)

    updated_user = UserDataFetcher.new(user).fetch

    updated_user.should be_a User
  end
end

describe UserDataFetcher, '#fetch' do
  it 'queries the Yammer Users API for Yammer Production data' do
    user = User.new(
      access_token: 'Tokenz',
      yammer_staging: false,
      yammer_user_id: 123456
    )
    oauth_hash = user.send(:yammer_user_data)
    before_user_id = user.yammer_user_id

    updated_user = UserDataFetcher.new(user).fetch

    before_user_id.should == user.yammer_user_id
    updated_user.yammer_staging?.should == false
    updated_user.email.should == oauth_hash['contact']['email_addresses'].
      first['address']
    updated_user.image.should == oauth_hash['mugshot_url']
    updated_user.name.should == oauth_hash['full_name']
    updated_user.nickname.should == oauth_hash['name']
    updated_user.yammer_profile_url.should == oauth_hash['web_url']
    updated_user.yammer_network_id.should == oauth_hash['network_id']
    updated_user.extra.should == oauth_hash.to_yaml
  end
end
