require 'spec_helper'

RSpec.describe NatsListener::ClientLogger do
  let(:logger) { double(:stub, info: ->(msg) { :info } ) }

  let(:opts) { { logger: logger } }

  describe '.initialize' do
    subject { described_class.new(opts) }

    context 'with logger' do
      it 'should set logger' do
        expect(subject.logger).to eq logger
      end
    end
  end
end
