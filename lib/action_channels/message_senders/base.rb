module ActionChannels
  module MessageSenders
    class Base
      def do_send(receiver, message)
      end

      def send_error_400(receiver)
        do_send receiver, Message.new(channel: '', type: 'bad_request')
      end
    end
  end
end
