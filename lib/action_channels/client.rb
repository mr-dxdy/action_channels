require 'timeout'

module ActionChannels
  class Client
    class << self
      def send_message(url, message, options = {})
        client = new(url, options)
        client.start
        client.send_message(message)
        client.stop

        true
      end
    end

    attr_reader :url, :message_sender

    def initialize(url, options = {})
      @url = url
      self.is_connected = false
      @message_sender = options.fetch :message_sender, MessageSenders::WebSocket.new
    end

    def start(waits_at = 20)
      return true if connected?

      do_connect

      Timeout::timeout(waits_at, Errors::NotConnected) do
        until connected? do
          sleep 1
        end
      end

      true
    end

    def stop
      if connected?
        connect.close
        connect = nil
      end

      true
    end

    def send_message(message)
      return false unless connected?

      message_sender.do_send(connect, message)

      true
    end

    def connected?
      is_connected
    end

    private

    attr_accessor :is_connected, :connect

    def do_connect
      client = self

      ::NIO::WebSocket.connect(url) do |websocket|
        on_open = lambda do |_|
          client.send 'connect=', websocket
          client.send 'is_connected=', true
        end

        websocket.on :open, on_open
      end
    end

  end
end
