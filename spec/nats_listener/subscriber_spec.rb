require 'spec_helper'

RSpec.describe NatsListener::Subscriber do
  describe '.client' do
    context 'with mock' do
      let(:new_client) { NatsListener::Client.new }
      before { allow(NatsListener::Client).to receive(:current).and_return(new_client) }
      subject { described_class.client }

      it 'should return nats listener' do
        expect(described_class.client.class).to eq NatsListener::Client
      end

      it 'should create client instance' do
        subject
        expect(NatsListener::Client).to have_received(:current)
      end

      it 'should return client' do
        expect(subject).to eq new_client
      end
    end
  end
end
