require 'delegate'

module ActionChannels
  class Driver < SimpleDelegator
    def data
      @data ||= {}
    end
  end
end
