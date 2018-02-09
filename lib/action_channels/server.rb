require 'nio/websocket'

module ActionChannels
  class Server
    attr_reader :port

    def initialize(port:)
      @port = port
    end

    def run
      NIO::WebSocket.listen port: port do |client|
        on_message = lambda do |event|
          ActionChannels.logger.info "Received new message: #{event.data}"

          message = Message.parse_and_setup_author event.data, client
          process_message message
        end

        on_close = lambda do |event|
          ActionChannels.logger.info "Client closed connection."
          channel_repository.all.each { |channel| channel.remove_client(client) }
        end

        client.on :message, on_message
        client.on :close, on_close
      end

      ActionChannels.logger.info "Server started on port: #{port}"
    end

    def channel_repository
      @channel_repository ||= ChannelRepository.new
    end

    private

    def process_message(message)
      channel = channel_repository.find_by_name_or_create message.channel
      channel.process_message message
    end
  end
end
