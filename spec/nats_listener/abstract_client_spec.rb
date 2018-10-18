require 'spec_helper'

RSpec.describe NatsListener::AbstractClient do
  describe '#with_connection' do
    let(:client_catcher) do
      double(call: ->(exception) { true })
    end
    let(:client) do
      client = described_class.new
      client.instance_variable_set(:@skip, false)
      client
    end

    subject { client.with_connection do; end }

    context 'without errors' do
      before { allow_any_instance_of(described_class).to receive(:reestablish_connection).and_return(true) }

      it 'should return true' do
        expect(subject).to be_truthy
      end
    end

    context 'with received error' do
      before do
        allow_any_instance_of(described_class).to receive(:reestablish_connection).and_raise(StandardError.new)
        allow_any_instance_of(described_class).to receive(:client_catcher).and_return(client_catcher)
        allow(client).to receive(:log).and_return(true)
      end

      it 'should raise error' do
        expect(subject).to be_falsey
      end

      it 'should call error catcher' do
        expect(client_catcher).to receive(:call)
        subject
      end

      it 'should call log' do
        expect(client).to receive(:log)
        subject
      end
    end
  end
end
