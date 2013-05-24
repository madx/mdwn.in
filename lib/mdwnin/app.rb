# encoding: utf-8

require 'sinatra'
require 'haml'

require 'mdwnin/models/document'

module Mdwnin
  class App < Sinatra::Base

    configure do
      set :app_file, __FILE__
    end

    get "/" do
      haml :read_only, locals: { document: Document.first }
    end

    get "/:key" do
      document = Document.first(key: params[:key])

      haml :read_only, locals: { document: Document.first }
    end
  end
end
