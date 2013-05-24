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
    Mdwnin::Document.create({raw_body: "Hello world"})
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

  describe "GET /:key" do
    describe "when :key references a document" do
      before { get "/#{first_document.key}"}

      it "show the document" do
        last_response.must_be :ok?
        last_response.body.must_match "<p>Hello world</p>"
      end
    end
  end


end
