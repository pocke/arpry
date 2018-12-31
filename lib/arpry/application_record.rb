module Arpry
  class ApplicationRecord < ActiveRecord::Base
    self.logger = Arpry::Logger.logger
  end
end
