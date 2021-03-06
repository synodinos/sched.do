require 'spec_helper'

describe User, 'accessors' do
  it { should allow_mass_assignment_of(:access_token) }
  it { should allow_mass_assignment_of(:encrypted_access_token) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:yammer_user_id) }
  it { should allow_mass_assignment_of(:yammer_staging) }
  it { should allow_mass_assignment_of(:watermarked_image) }
end

describe User, 'validations' do
  it { should have_many(:events) }
  it { should have_many(:invitations) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:yammer_user_id) }
  it { should validate_presence_of(:encrypted_access_token) }

  it 'requires a valid e-mail address' do
    should allow_value('person@example.com').for(:email)
    should allow_value('person-awesome@example.com').for(:email)
    should allow_value('person-awesome@example.co.ul.com').for(:email)
    should allow_value(' person@example.com').for(:email)
    should allow_value('person@example.com  ').for(:email)
    should_not allow_value('person@@example.com').for(:email)
    should_not allow_value('person').for(:email)
    should_not allow_value('person @person.com').for(:email)
  end

  context 'encrypted_access_token' do
    it 'encrypts access_token before validation on create' do
      access_token = 'abc123'
      expected_encrypted_access_token =
        Encryptor.encrypt(access_token, key: ENV['ACCESS_TOKEN_ENCRYPTION_KEY'])
      expected_encrypted_access_token =
        Base64.encode64(expected_encrypted_access_token)
      user = build(:user, access_token: access_token)

      user.save
      user.encrypted_access_token.should == expected_encrypted_access_token
    end
  end
end

describe User, 'has_attached_file' do
  it { should have_attached_file(:watermarked_image) }
end

describe User, '#associate_guest_invitations' do
  it 'associates all guest invitations with this user' do
    invitation = create(:invitation_with_guest)
    guest = invitation.invitee
    guest_invitation_ids = guest.invitations.map(&:id)
    user = create(:user, email: guest.email)

    user.associate_guest_invitations

    user.invitations.map(&:id).should == guest_invitation_ids
  end

  it 'deletes the guest which we found' do
    invitation = create(:invitation_with_guest)
    guest = invitation.invitee
    user = create(:user, email: guest.email)

    user.associate_guest_invitations

    guest_check = Guest.find_by_email(guest.email)
    guest_check.should be_nil
  end
end

describe User, '#in_network?' do
  it 'returns true if user is in network' do
    user = build_stubbed(:user, yammer_network_id: 1)
    in_network_user = build_stubbed(:user, yammer_network_id: 1)

    user.should be_in_network(in_network_user)
  end

  it 'returns false if user is out network' do
    user = build_stubbed(:user, yammer_network_id: 1)
    in_network_user = build_stubbed(:user, yammer_network_id: 2)

    user.should_not be_in_network(in_network_user)
  end
end

describe User, '#able_to_edit?' do
  it 'returns true if the user created the event' do
    event = create(:event)
    user = event.owner
    event.owner.should be_able_to_edit(event)
  end

  it 'returns false if the user did not create the event' do
    event = create(:event)
    build(:user).should_not be_able_to_edit(event)
  end
end

describe User, '#image' do
  it 'returns the placeholder if there is no image' do
    user = build_stubbed(:user, image: nil)

    user.image.should == 'http://' + ENV['HOSTNAME'] + '/assets/no_photo.png'
  end

  it 'returns the absolute image url if one exists' do
    user = create(:user)
    user.image.should include('https://mug0.assets-yammer.com/')
  end
end

describe User, '#votes' do
  it 'returns the users votes if there are any' do
    user = create(:user)
    vote = create(:vote, voter: user)
    user.votes.should == [vote]
  end

  it 'returns an empty array if the user has no votes' do
    user = build(:user)
    user.votes.should == []
  end
end

describe User, '#vote_for_suggestion' do
  it 'returns the users vote for the given suggestion if the user has one' do
    user = create(:user)
    vote = create(:vote, voter: user)
    user.vote_for_suggestion(vote.suggestion).should == vote
  end

  it 'returns nil if the user has not voted on the suggestion' do
    user = create(:user)
    suggestion = create(:suggestion)
    user.vote_for_suggestion(suggestion).should be_nil
  end
end

describe User, '#voted_for_suggestion?' do
  it 'returns true if the user voted for the suggestion' do
    user = create(:user)
    vote = create(:vote, voter: user)
    user.voted_for_suggestion?(vote.suggestion).should be_true
  end

  it 'returns false if the user did not vote for the suggestion' do
    user = create(:user)
    suggestion = create(:suggestion)
    user.voted_for_suggestion?(suggestion).should be_false
  end
end

describe User, '#voted_for_event?' do
  it 'returns true if the user voted for the event' do
    user = create(:user)
    vote = create(:vote, voter: user)
    user.voted_for_event?(vote.event).should be_true
  end

  it 'returns false if the user did not vote for the event' do
    user = create(:user)
    event = create(:event)

    user.voted_for_event?(event).should be_false
  end
end

describe User, '#fetch_yammer_user_data' do
  it 'queries the Yammer Users API for Yammer Production data' do
    user = User.new(
      access_token: 'Tokenz',
      yammer_staging: false,
      yammer_user_id: 123456
    )
    oauth_hash = user.send(:yammer_user_data)
    before_user_id = user.yammer_user_id

    user.fetch_yammer_user_data

    user.reload
    before_user_id.should == user.yammer_user_id
    user.yammer_staging?.should == false
    user.email.should == oauth_hash['contact']['email_addresses'].
      first['address']
    user.image.should == oauth_hash['mugshot_url']
    user.name.should == oauth_hash['full_name']
    user.nickname.should == oauth_hash['name']
    user.yammer_profile_url.should == oauth_hash['web_url']
    user.yammer_network_id.should == oauth_hash['network_id']
    user.yammer_network_name.should == oauth_hash['network_name']
    user.extra.should == oauth_hash.to_yaml
  end
end

describe User, '#yammer_user?' do
  it 'always returns true' do
    build(:user).should be_yammer_user
  end
end

describe User, '#invite' do
  include DelayedJobSpecHelper

  it 'if the user is out-network, it sends an email notification' do
    invitee = create(:out_network_user)
    invitation = build(:invitation_with_user, invitee: invitee)
    messenger_instance = mock('messenger instance', :invite)
    Messenger.expects(:new).
      with(invitation, invitation.sender).
      returns(messenger_instance)

    organizer = invitation.sender
    event = invitation.event

    invitee.invite(invitation)
    work_off_delayed_jobs

    organizer.should_not be_in_network(invitee)
    messenger_instance.should have_received(:invite)
  end

  it 'sends a private message notification, if the user is in-network' do
    invitee = build_stubbed(:user)
    invitation = build_stubbed(:invitation_with_user, invitee: invitee)
    organizer = invitation.sender
    owner = invitation.event.owner

    invitee.remind(invitation, owner)
    work_off_delayed_jobs

    organizer.should be_in_network(invitee)
    FakeYammer.messages_endpoint_hits.should == 1
    FakeYammer.message.should include(invitation.event.name)
  end
end

describe User, '#remind' do
  include DelayedJobSpecHelper

  it 'hits the Yammer messages API, if the user is in-network' do
    invitee = build_stubbed(:user)
    invitation = build_stubbed(:invitation_with_user,
                               invitee: invitee)

    expect {
      invitee.remind(invitation, invitation.sender)
      work_off_delayed_jobs
    }.to change(FakeYammer, :messages_endpoint_hits).by(1)
  end
end

describe User, '#update_watermark' do
  it 'does not update the watermark for users without an existing watermark' do
    user = build(:user, watermarked_image: nil)

    user.update_watermark

    user.watermarked_image.url.should ==
      "/watermarked_images/original/missing.png"
  end
end

describe User, '#watermark' do
  it 'returns a URL string pointing to the event owner profile photo' do
    user = build(:user)

    user.watermark.should == user.image
  end
end
