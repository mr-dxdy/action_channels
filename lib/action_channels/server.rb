require 'nio/websocket'

module ActionChannels
  class Server
    attr_reader :port

    def initialize(port:)
      @port = port
    end

    def run
      NIO::WebSocket.listen port: port do |client|
        process_client client
      end

      ActionChannels.logger.info "Server started on port: #{port}"
    end

    def channel_repository
      @channel_repository ||= ChannelRepository.new
    end

    def process_client(client)
      client.on :message, callback_on_message(client)
      client.on :close, callback_on_close(client)
      client.on :error, callback_on_error(client)
      client.on :io_error, callback_on_io_error(client)

      client
    end

    private

    def callback_on_message(client)
      lambda do |event|
        begin
          ActionChannels.logger.info "Received new message: #{event.data}"

          message = Message.parse_and_setup_author event.data, client
          process_message message
        rescue Errors::NotParseMessage => exp
          ActionChannels.logger.error exp.message
          message_sender.send_error_400 client
        end
      end
    end

    def message_sender
      @message_sender ||= MessageSenders::WebSocket.new
    end

    def callback_on_io_error(client)
      proc do
        ActionChannels.logger.error "Received io_error."
        channel_repository.all.each { |channel| channel.remove_client(client) }
      end
    end

    def callback_on_error(client)
      lambda do |event|
        ActionChannels.logger.error "Received error: #{event.message}"
        channel_repository.all.each { |channel| channel.remove_client(client) }
      end
    end

    def callback_on_close(client)
      lambda do |event|
        ActionChannels.logger.info "Client closed connection."
        channel_repository.all.each { |channel| channel.remove_client(client) }
      end
    end

    def process_message(message)
      channel = channel_repository.find_by_name_or_create message.channel
      channel.process_message message
    end
  end
end
