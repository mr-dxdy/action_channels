module ActionChannels
  module MessageSenders
    class Buffer < Base
      def do_send(receiver, message)
        queue << [receiver, message]
      end

      def queue
        @queue ||= []
      end
    end
  end
end
