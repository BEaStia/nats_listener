# frozen_string_literal: true

require_relative './abstract_subscriber'

module NatsListener
  # Base subscriber using nats-streaming
  class StreamingSubscriber < AbstractSubscriber
    class << self
      def client
        NatsListener::StreamingClient.current
      end
    end
  end
end
