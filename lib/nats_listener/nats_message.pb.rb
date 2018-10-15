# encoding: utf-8

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "NatsListener.NatsMessage" do
    optional :sender_service_name, :string, 1
    optional :receiver_action_name, :string, 2
    repeated :receiver_action_parameters, :string, 3
    optional :message_timestamp, :int64, 4
    optional :transaction_id, :string, 5
  end
end

module NatsListener
  NatsMessage = Google::Protobuf::DescriptorPool.generated_pool.lookup('NatsListener.NatsMessage').msgclass
end

