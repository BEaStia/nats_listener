# frozen_string_literal: true

module NatsListener
  # Client configuration
  class ClientLogger
    attr_reader :logger

    def initialize(opts)
      @logger = opts[:logger]
    end

    def log(action:, message:, service_name:)
      return unless logger

      logger.info(
        service: service_name,
        action: action,
        message: message
      )
    end
  end
end
