require 'spec_helper'

describe :FollowActor do
  let(:client_pool) { double('client_pool') }
  let(:user_followers_manager) { double('user_followers_manager') }
  let(:user_being_followed) { 1 }
  let(:follower) { 2 }
  let(:message) { 'Yay! User 2 is now following you.' }

  context :act do
    it 'registers a follower and notifies the user followed' do
      expect(client_pool).to receive(:notify).with(user_being_followed, message)
      expect(user_followers_manager).to receive(:register_follower).with(user_being_followed, follower)

      actor = FollowActor.new user_followers_manager, client_pool
      actor.act user_being_followed, follower
    end

    #other option would be to configure retries
    it 'ignores errors while trying to notify the followed user' do
      expect(client_pool).to receive(:notify).with(user_being_followed, message).and_raise(ClientNotFoundError)
      expect(user_followers_manager).to receive(:register_follower).with(user_being_followed, follower)

      actor = FollowActor.new user_followers_manager, client_pool
      actor.act user_being_followed, follower
    end

    #a possible scneario would be registering a follower for a user that does not exist
  end
end