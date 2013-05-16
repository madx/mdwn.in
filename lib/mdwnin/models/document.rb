
# encoding: utf-8

require 'sequel'

require 'mdwnin/keygen'

module Mdwnin
  class Document < Sequel::Model

    def before_save
      self.key ||= Keygen.generate

      super
    end
  end
end

