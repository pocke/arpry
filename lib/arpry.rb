require 'active_record'
require 'pry'
require 'logger'

require "arpry/version"
require 'arpry/cli'
require 'arpry/logger'
require 'arpry/application_record'

module Arpry
  class Error < StandardError; end

  # Namespace for automatically generated classes
  module Namespace
  end
end
