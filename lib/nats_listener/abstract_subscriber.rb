# frozen_string_literal: true

module NatsListener
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

    def initialize(subj: nil, count: nil)
      @subject = subj || self.class.const_get('SUBJECT')
      @count = count || self.class.const_get('COUNT')
      @infinitive = true if @count.zero?
    end

    def subscribe(opts = {})
      # Create subscription and delete after its finished if not infinitive
      @sid = client.subscribe(@subject, opts) do |msg, reply, subject|
        begin
          around_call(msg, reply, subject)
        rescue StandardError => exception
          client.on_rescue(exception)
        end
      end
    end

    def around_call(msg, reply, subject)
      client.log(action: :received, message: msg)
      if @count.positive? || @infinitive
        call(msg, reply, subject)
        @count -= 1 unless @infinitive
      else
        destroy
      end
    end

    def destroy
      client.unsubscribe(@sid)
    end

    def call(msg, reply, subject); end
  end
end
