# encoding: utf-8

require 'sinatra'
require 'haml'

require 'mdwnin/models/document'

module Mdwnin
  class App < Sinatra::Base

    configure do
      set :app_file, __FILE__
      set :haml, { attr_wrapper: '"' }

      enable :method_override
    end

    helpers do
      def document_editor_params(document, editable)
        {
          method: 'POST',
          action: url(editable ? "/#{document.key}" : "/")
        }
      end
    end

    get "/" do
      haml :read_only, locals: { document: Document.first }
    end

    get "/new" do
      haml :form, locals: { document: Document.new }
    end

    get "/gh/:user/:repo" do
      uri = URI("https://raw.github.com/#{params[:user]}/#{params[:repo]}/master/README.md")
      content = Net::HTTP.get(uri).force_encoding('utf-8')

      document = Document.new(raw_body: content)
      document.compile

      haml :read_only, locals: { document: document }
    end

    get "/:key" do
      document = Document.first(key: params[:key])

      haml :read_write, locals: { document: document }
    end

    get "/:key/edit" do
      document = Document.first(key: params[:key])

      haml :form, locals: { document: document, edit: true }
    end

    post "/" do
      document = Document.create(params[:document])

      redirect to("/#{document.key}")
    end

    put "/:key" do
      document = Document.first(key: params[:key])

      document.update_fields(params[:document], [:raw_body])

      redirect to("/#{document.key}")
    end
  end
end
