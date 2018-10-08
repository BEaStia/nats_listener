# frozen_string_literal: true

module NatsListener
  class Subscriber
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

    class << self
      # subject method is used to define subject for subscription
      def subject(subj)
        const_set('SUBJECT', subj)
      end

      # count method is used to define count of publications
      # that subscription listens to
      # If 0 - it's infinitive
      # Otherwise it decrements after each publication
      def count(count = 0)
        const_set('COUNT', count)
      end
    end

    def initialize(subj: nil, count: nil)
      @subject = subj || self.class.const_get('SUBJECT')
      @count = count || self.class.const_get('COUNT')
      @infinitive = true if @count.zero?
    end

    def subscribe
      # Create subscription and delete after its finished if not infinitive
      @sid = NatsListener::Client.current.subscribe(@subject) do |msg, reply, subject|
        if @count.positive? || @infinitive
          call(msg, reply, subject)
          @count -= 1 unless @infinitive
        else
          NatsListener::Client.current.unsubscribe(@sid)
        end
      end
    end

    def call(msg, reply, subject); end
  end
end
