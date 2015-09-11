require 'spec_helper'

describe :BroadcastActor do
  let(:client_pool) { double('client_pool') }
  let(:actor) { BroadcastActor.new client_pool }
  let(:message) { 'my broadcast message' }

  context :act do
    it 'sends the message to the client pool' do
      expect(client_pool).to receive(:broadcast).with(message)
      actor.act(message)
    end

    it 'ignores errors from the client pool' do
      expect(client_pool).to receive(:broadcast).with(message).and_raise(ClientNotFoundError)
      actor.act(message)
    end
  end
end