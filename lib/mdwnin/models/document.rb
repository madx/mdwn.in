
# encoding: utf-8

require 'sequel'

require 'mdwnin/keygen'
require 'mdwnin/models/revision'

module Mdwnin
  class Document < Sequel::Model
    one_to_many :revisions

    def before_save
      self.key ||= Keygen.generate

      super
    end
  end
end

