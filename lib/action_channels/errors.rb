module ActionChannels
  module Errors
    class Base < StandardError; end
    class NotParseMessage < Base; end
    class NotConnected < Base; end
  end
end
