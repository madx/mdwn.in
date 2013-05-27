# encoding: utf-8

require 'net/http'

require 'sinatra'
require 'haml'

require 'mdwnin/models/document'

module Mdwnin
  class App < Sinatra::Base

    require 'sinatra/content_for'
    helpers Sinatra::ContentFor

    configure do
      set :app_file, __FILE__
      set :haml, { attr_wrapper: '"' }

      enable :method_override
    end

    require 'sinatra/reloader' if development?
    configure :development do
      register Sinatra::Reloader
    end

    helpers do
      def document_editor_params(document, editable)
        {
          method: 'POST',
          action: url(editable ? "/#{document.key}" : "/")
        }
      end

      def title
        @title ? "#{@title} - " : nil
      end

      def set_title(title)
        @title = title
      end
    end

    get "/" do
      haml :read_only, locals: { document: Document.order(:id).first }
    end

    get "/new" do
      set_title "New document"
      haml :form, locals: { document: Document.new }
    end

    get "/gh/:user/:repo" do
      set_title "#{params[:user]}/#{params[:repo]}"

      # TODO: Test this and make it error-proof
      uri = URI("https://raw.github.com/#{params[:user]}/#{params[:repo]}/master/README.md")
      content = Net::HTTP.get(uri).force_encoding('utf-8')

      document = Document.new(source: content)
      document.compile

      haml :read_only, locals: { document: document }
    end

    get %r{^/([a-z0-9]{64})$} do |read_only_key|
      document = Document.first(read_only_key: read_only_key)

      raise Sinatra::NotFound if document.nil?

      set_title document.title
      haml :read_only, locals: { document: document }
    end

    get "/:private_key" do
      document = Document.first(key: params[:private_key])

      raise Sinatra::NotFound if document.nil?

      set_title document.title
      haml :read_write, locals: { document: document }
    end

    get "/:key/edit" do
      document = Document.first(key: params[:key])

      set_title document.title + ' (Edit)'
      haml :form, locals: { document: document, edit: true }
    end

    post "/" do
      document = Document.create(params[:document])

      redirect to("/#{document.key}")
    end

    post "/render" do
      source = params[:source] || ""

      erb Markdown.render(source)
    end

    put "/:key" do
      document = Document.first(key: params[:key])

      document.update_fields(params[:document], [:source])

      redirect to("/#{document.key}")
    end

    not_found do
      set_title "Not Found"
      haml :not_found
    end

    error do
      set_title "Error"
      haml :error
    end
  end
end
