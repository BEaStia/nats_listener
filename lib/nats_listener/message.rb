module NatsListener
  class Message
    attr_reader :message

    def initialize(data)
      @message = build_message(data)
    end

    def to_json
      message.to_json
    end

    private

    def build_message(data)
      {
        publisher: NatsListener::Client.current.service_name,
        timestamp: Time.now.utc,
        message_id: SecureRandom.uuid,
        data: data
      }
    end
  end
end
