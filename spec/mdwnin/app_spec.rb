# encoding: utf-8

require 'spec_helper'
require 'rack/test'

require 'mdwnin/app'

describe Mdwnin::App do
  include MiniTest::Spec::Sequel
  include Rack::Test::Methods

  def app
    Mdwnin::App
  end

  before do
    # Ensure the first document is always created
    Mdwnin::Document.create({source: "Hello world"})
  end

  let(:first_document) { Mdwnin::Document.first }

  describe "GET /" do
    before { get "/" }

    it "is ok" do
      last_response.must_be :ok?
    end

    it "shows the first document" do
      last_response.body.must_match "<p>Hello world</p>"
    end

    it "shows a read-only version" do
      last_response.body.wont_match "#{first_document.key}/edit"
    end
  end

  describe "GET /new" do
    before { get "/new" }

    it "show a form to create a document" do
      last_response.body.must_match 'textarea'
    end

    it "builds a form with the POST method" do
      last_response.body.must_match 'method="POST"'
    end
  end

  describe "GET /:read_only_key" do
    describe "when :read_only_key references a document" do
      it "is ok" do
        get "/#{first_document.read_only_key}"

        last_response.must_be :ok?
      end

      it "shows the given document" do
        document = Mdwnin::Document.create(source: "New document")
        get "/#{document.read_only_key}"

        last_response.body.must_match "<p>New document</p>"
      end

      it "shows an read-only version" do
        get "/#{first_document.read_only_key}"

        last_response.body.wont_match "#{first_document.key}/edit"
      end
    end

    describe "when :read_only_key does not reference a document" do
      it "returns a 404" do
        get "/00000000000000000000000000000000000000000000000000000000"

        last_response.must_be :not_found?
      end
    end
  end

  describe "GET /:private_key" do
    describe "when :private_key references a document" do
      it "is ok" do
        get "/#{first_document.key}"

        last_response.must_be :ok?
      end

      it "shows the given document" do
        document = Mdwnin::Document.create(source: "New document")
        get "/#{document.key}"

        last_response.body.must_match "<p>New document</p>"
      end

      it "shows an editable version" do
        get "/#{first_document.key}"

        last_response.body.must_match "#{first_document.key}/edit"
      end

      it "show a sharing link" do
        get "/#{first_document.key}"

        last_response.body.must_match "#{first_document.read_only_key}"
      end
    end

    describe "when :private_key does not reference a document" do
      it "returns a 404" do
        get "/abcd.123"

        last_response.must_be :not_found?
      end
    end
  end

  describe "GET /:key/edit" do
    describe "when :key references a document" do
      it "is ok" do
        get "/#{first_document.key}/edit"

        last_response.must_be :ok?
      end

      it "shows the editor for the given document" do
        document = Mdwnin::Document.create(source: "New document")
        get "/#{document.key}/edit"

        last_response.body.must_match "textarea"
        last_response.body.must_match "New document"
      end

      it "puts the document id in an hidden field" do
        get "/#{first_document.key}/edit"

        last_response.body.must_match first_document.key
      end

      it "builds a form with the PUT method override" do
        get "/#{first_document.key}/edit"

        last_response.body.must_match 'name="_method"'
        last_response.body.must_match 'value="PUT"'
      end
    end

    describe "when :key does not reference a document" do
      # TODO
    end
  end

  describe "POST /" do
    describe "with valid parameters" do
      it "creates a new document" do
        before_count = Mdwnin::Document.count
        post "/", document: { source: "Hello world" }
        after_count = Mdwnin::Document.count

        after_count.must_equal(before_count + 1)
      end

      it "redirects to the new document" do
        post "/", document: { source: "Hello world" }
        follow_redirect!

        last_request.url.must_match Mdwnin::Document.last.key
      end
    end

    describe "with invalid parameters" do
      it "returns a 400" do
        post "/"

        last_response.status.must_equal 400
      end
    end

    describe "reverse captcha" do
      it "should refuse the document if donotfill is filled" do
        post "/", document: { source: "Hello world", donotfill: "I'm a robot'"}

        last_response.status.must_equal 500
      end

      it "should accept the document if donotfill is empty" do
        post "/", document: { source: "Hello world", donotfill: ""}

        last_response.must_be :redirect?
      end
    end
  end

  describe "POST /render" do
    it "is ok" do
      post "/render"

      last_response.must_be :ok?
    end

    it "returns the rendered document givent with source" do
      post "/render", source: "Hello world"

      last_response.body.must_equal "<p>Hello world</p>\n"
    end
  end

  describe "PUT /:key" do
    describe "when :key references a document" do

      let(:document_url) { "/" + first_document.key }

      describe "with valid parameters" do
        it "updates the document" do
          put document_url, document: { source: "Updated content" }
          follow_redirect!

          last_response.body.must_match "<p>Updated content</p>"
        end

        it "does not create a new document" do
          before_count = Mdwnin::Document.count
          put "/#{first_document.key}", document: { source: "Updated content" }
          after_count = Mdwnin::Document.count

          after_count.must_equal(before_count)
        end

        it "redirects to the updated document" do
          put document_url, document: { source: "Updated content" }
          follow_redirect!

          last_request.url.must_match first_document.key
        end
      end

      describe "with invalid parameters" do
        it "redirects to the edit page" do
          put document_url
          follow_redirect!

          last_request.url.must_match "edit"
          last_request.url.must_match first_document.key
        end
      end

      describe "reverse captcha" do
        it "should refuse the document if donotfill is filled" do
          put document_url, document: { source: "Hello world", donotfill: "I'm a robot'"}

          last_response.status.must_equal 500
        end

        it "should accept the document if donotfill is empty" do
          put document_url, document: { source: "Hello world", donotfill: ""}

          last_response.must_be :redirect?
        end
      end
    end

    describe "when :key does not reference a document" do
      # TODO
    end
  end
end
