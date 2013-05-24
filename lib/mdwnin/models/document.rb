# encoding: utf-8

require 'sequel'

require 'mdwnin/keygen'
require 'mdwnin/markdown'

module Mdwnin
  class Document < Sequel::Model
    plugin :validation_helpers

    def validate
      super

      validates_presence [:raw_body]
    end

    def before_create
      self.key = Keygen.generate
      self.read_only_key = Digest::SHA256.hexdigest(key)

      super
    end

    def before_save
      self.compiled = Markdown.render(raw_body)

      super
    end

    def title
      regexp = %r{<h(\d)[^>]*>([^<]+)</h\1>}
      headers = compiled.scan(regexp).map { |_, t| t }

      headers.first or "Untitled"
    end
  end
end

