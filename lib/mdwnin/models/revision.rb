# encoding: utf-8

require 'sequel'

require 'mdwnin/markdown'

module Mdwnin
  class Revision < Sequel::Model
    plugin :validation_helpers

    def validate
      super

      validates_presence [:raw_body]
    end

    def before_save
      self.compiled = Markdown.render(raw_body)

      super
    end
  end
end

