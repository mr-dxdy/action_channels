module ActionChannels
  class Channel
    def self.input_message_types
      %w(subscribe unsubscribe publish)
    end

    def self.output_message_types
      %w(subscribed unsubscribed published news invalid_message)
    end

    attr_reader :name, :clients
    attr_accessor :message_sender

    def initialize(name:, message_sender: MessageSenders::WebSocket.new)
      @name = name
      @clients = Set.new
      @message_sender = message_sender
    end

    def send_message(receiver, message)
      message_sender.do_send(receiver, message)
    end

    def add_client(client)
      clients << client
      ActionChannels.logger.info "The channel #{self.name} added a client"
    end

    def remove_client(client)
      clients.delete client
      ActionChannels.logger.info "The channel #{self.name} removed a client"
    end

    def notify_all(message)
      clients.each do |client|
        send_message client, message
      end
    end

    def process_message(message)
      ActionChannels.logger.info "The channel #{self.name} received a message #{message.inspect}"

      case message.type
      when 'subscribe'
        on_subscribe message.author, message.details
      when 'unsubscribe'
        on_unsubscribe message.author, message.details
      when 'publish'
        on_publish message.author, message.details
      else
        on_unknown_type_message message.author, message.type
      end
    end

    private

    def on_subscribe(subscriber, details)
      add_client(subscriber)
      send_message subscriber, Message.new(channel: name, type: 'subscribed')
    end

    def on_unsubscribe(subscriber, details)
      remove_client(subscriber)
      send_message subscriber, Message.new(channel: name, type: 'unsubscribed')
    end

    def on_publish(speaker, details)
      notify_all Message.new(channel: name, type: 'news', details: details)
      send_message speaker, Message.new(channel: name, type: 'published')
    end

    def on_unknown_type_message(user, type)
      send_message user, Message.new(channel: name, type: 'invalid_message', details: { error: "Unknown type of message: #{type}" })
    end
  end
end
