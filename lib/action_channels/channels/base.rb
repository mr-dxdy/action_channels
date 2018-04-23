module ActionChannels
  module Channels
    class Base
      attr_reader :name, :clients
      attr_accessor :message_sender

      def initialize(attrs)
        @name = attrs.fetch(:name)
        @clients = Set.new
        @message_sender = attrs.fetch :message_sender, MessageSenders::WebSocket.new
      end

      def send_message(receiver, message)
        message_sender.do_send(receiver, message)
      end

      def add_client(client)
        clients << client

        ActionChannels.logger.info "The channel ##{self.name} added a client"
        ActionChannels.logger.debug "Count of client of channel ##{self.name} is #{self.clients.count}."
      end

      def remove_client(client)
        clients.delete client

        ActionChannels.logger.info "The channel ##{self.name} removed a client"
        ActionChannels.logger.debug "Count of client of channel ##{self.name} is #{self.clients.count}."
      end

      def notify_all(message)
        clients.each do |client|
          send_message client, message
        end
      end

      def process_message(message)
        ActionChannels.logger.debug "The channel ##{self.name} received a message #{message.inspect}"

        if message.systemic?
          process_system_message message
        else
          process_custom_message message
        end
      end

      def process_system_message(message)
        case message.type
        when 'subscribe'
          on_subscribe message.author, message.details
        when 'unsubscribe'
          on_unsubscribe message.author, message.details
        else
        end
      end

      def process_custom_message(message)
        # nothing
      end

      def after_message_subscribe(subscriber, details)
        # nothing
      end

      def after_message_unsubscribe(subscriber, details)
        # nothing
      end

      private

      def on_subscribe(subscriber, details)
        add_client(subscriber)
        send_message subscriber, Message.new(channel: name, type: 'subscribed')
        after_message_subscribe subscriber, details
      end

      def on_unsubscribe(subscriber, details)
        remove_client(subscriber)
        send_message subscriber, Message.new(channel: name, type: 'unsubscribed')
        after_message_unsubscribe subscriber, details
      end

      def on_unknown_type_message(message)
        user, type = message.author, message.type
        send_message user, Message.new(channel: name, type: 'invalid_message', details: { error: "Unknown type of message: #{type}" })
      end
    end
  end
end
