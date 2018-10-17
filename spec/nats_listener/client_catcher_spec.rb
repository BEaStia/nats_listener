require 'spec_helper'

RSpec.describe NatsListener::ClientCatcher do
  let(:catch_provider) do
    double(:stub, error: ->(exception) { :error } )
  end

  let(:catch_errors) { true }
  let(:opts) do
    {
      catch_errors: catch_errors,
      catch_provider: catch_provider
    }
  end

  describe '.current' do
    subject { described_class.new(opts) }

    context 'with catch_errors' do
      it 'should set catch_errors' do
        expect(subject.catch_error).to eq true
      end
    end

    context 'without catching errors' do
      let(:catch_errors) { false }

      it 'should set catch_errors' do
        expect(subject.catch_error).to eq false
      end
    end
  end

  describe '#call' do
    let(:catcher) { described_class.new(opts) }
    let(:exception) { NameError.new }

    subject { catcher.call(exception) }

    context 'with enabled error catching' do

      it 'should call error method' do
        expect(catch_provider).to receive(:error)
        subject
      end

      it 'should not raise exception' do
        expect { subject }.not_to raise_exception
      end
    end

    context 'with disabled error catching' do
      let(:catch_errors) { false }
      it 'should raise exception' do
        expect { subject }.to raise_exception(NameError)
      end
    end
  end
end
