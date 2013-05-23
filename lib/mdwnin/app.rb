# encoding: utf-8

require 'sinatra'

require 'mdwnin/models/document'

module Mdwnin
  class App < Sinatra::Base

    get '/' do
      "Hello world"
    end
  end
end
