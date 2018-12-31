module Arpry
  module Logger
    extend self
    attr_accessor :logger

    self.logger = ::Logger.new(STDOUT)
  end
end
