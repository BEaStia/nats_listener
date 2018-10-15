module NatsListener
  class AbstractClient
    attr_reader :service_name, :logger, :skip, :catch_errors, :catch_provider, :nats

    def log(action:, message:)
      logger.info(service: service_name, action: action, message: message) if logger
    end

    def with_connection
      return if skip
      begin
        reestablish_connection
        yield
      rescue StandardError => exception
        if catch_errors
          log(action: :error, message: exception)
          catch_provider.error(exception) if catch_provider
        else
          raise exception
        end
      end
    end

    # Raw method to publish subject to data
    def publish(subject, message)
      with_connection do
        log(action: :publish, message: message)
        nats.publish(subject, message)
      end
    end

    # Raw method, beware of using it in favor of Subscribers objects
    def subscribe(subject, opts, &callback)
      with_connection do
        nats.subscribe(subject, opts, &callback)
      end
    end

    # Raw method, beware of using it in favor of Subscribers objects
    def unsubscribe(sid)
      with_connection do
        nats.unsubscribe(sid)
      end
    end
  end
end
