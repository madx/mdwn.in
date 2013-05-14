# encoding: utf-8

require 'sequel'

module Mdwnin
  class Revision < Sequel::Model
    plugin :validation_helpers

    def validate
      super

      validates_presence [:raw_body]
    end
  end
end

