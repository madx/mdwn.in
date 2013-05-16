# encoding: utf-8

require 'sequel'

require 'mdwnin/markdown'
require 'mdwnin/models/document'

module Mdwnin
  class Revision < Sequel::Model
    plugin :validation_helpers

    many_to_one :document

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

