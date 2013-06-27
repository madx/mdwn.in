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

      def filter_spam(params)
        donotfill = params.delete("donotfill")

        halt 500, "Get out, fucking spammer" if donotfill && !donotfill.empty?
      end
    end

    get "/" do
      haml :read_only, locals: { document: Document.order(:id).first }
    end

    get "/new" do
      set_title "New document"
      haml :editor, locals: { document: Document.new }
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
      haml :editor, locals: { document: document, edit: true }
    end

    post "/" do
      attrs = params[:document] || {}
      filter_spam(attrs)

      document = Document.new(attrs)

      begin
        document.save
        redirect to("/#{document.key}")
      rescue Sequel::ValidationFailed
        halt 400, haml(:editor, locals: { document: document })
      end
    end

    post "/render" do
      source = params[:source] || ""

      erb Markdown.render(source), layout: false
    end

    put "/:key" do
      attrs = params[:document] || {}
      filter_spam(attrs)

      document = Document.first(key: params[:key])

      begin
        document.update_fields(attrs, [:source])

        halt 200, Time.now.strftime("Saved at %T") if request.xhr?
        redirect to("/#{document.key}")
      rescue Sequel::ValidationFailed, Sequel::InvalidValue
        halt 400, "Save failed" if request.xhr?
        redirect to("/#{document.key}/edit")
      end
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
