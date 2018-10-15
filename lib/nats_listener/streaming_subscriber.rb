# frozen_string_literal: true

module NatsStreamingListener
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

    def subscribe(opts = {})
      # Create subscription and delete after its finished if not infinitive
      @sid = NatsStreamingListener::Client.current.subscribe(@subject, opts) do |msg, reply, subject|
        begin
          client = NatsStreamingListener::Client.current
          client.log(action: :received, message: msg)
          if @count.positive? || @infinitive
            call(msg, reply, subject)
            @count -= 1 unless @infinitive
          else
            client.unsubscribe(@sid)
          end
        rescue StandardError => exception
          if client.catch_errors
            client.log(action: :error, message: msg)
            client.catch_provider.error(exception) if client.catch_provider
          else
            raise exception
          end
        end
      end
    end

    def call(msg, reply, subject); end
  end
end
