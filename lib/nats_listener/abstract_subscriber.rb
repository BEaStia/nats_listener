# frozen_string_literal: true

module NatsListener
  # Abstract class for nats and nats-streaming subscriptions
  class AbstractSubscriber
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

    attr_reader :client, :sid

    def initialize
      klass = self.class
      @subject = klass.const_get('SUBJECT')
      @count = klass.const_get('COUNT')
      @client = klass.client
      @infinitive = true if @count.zero?
    end

    def subscribe(opts = {})
      # Create subscription and delete after its finished if not infinitive
      @sid = client.subscribe(@subject, opts) do |msg, reply, subject|
        begin
          around_call(msg, reply, subject)
          destroy unless should_call?
        rescue StandardError => exception
          client.on_rescue(exception)
        end
      end
    end

    def around_call(msg, reply, subject)
      client.log(action: :received, message: msg.to_json)
      return unless should_call?

      call(msg, reply, subject)
      @count -= 1 unless @infinitive
    end

    def should_call?
      @count.positive? || @infinitive
    end

    def destroy
      client.unsubscribe(sid)
    end

    def call(_msg, _reply, _subject); end
  end
end
