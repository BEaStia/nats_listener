# frozen_string_literal: true
require_relative './abstract_subscriber'
module NatsListener
  class Subscriber < AbstractSubscriber
    # It's just a small example of subscriber usage:
    #
    # class TestSubscriber < Subscriber
    #   subject 'test'
    #   count 1
    #
    #   def call(msg, reply, subject)
    #     p "#{msg} #{subject}"
    #   end
    # end
    #
    # Then we execute
    #   Clients::Nats::Client.instance.publish('test', 'Hello, World')
    # And receive 'Hello, World test'
    # Next publish of this message won't show anything
    #

    def client
      NatsListener::Client.current
    end
  end
end
