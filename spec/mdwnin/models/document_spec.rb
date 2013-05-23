
# encoding: utf-8

require 'spec_helper'

require 'mdwnin/models/document'

class Mdwnin::DocumentSpec < SequelSpec
  subject { Mdwnin::Document }
  let(:valid_data) {
    { raw_body: "Hello world" }
  }

  describe "before create" do
    it "generates an unique key with the keygen" do
      Mdwnin::Keygen.stub(:generate, "hello") do
        document = subject.create(valid_data)
        document.key.must_equal "hello"
      end
    end

    it "generates the associated read only key" do
      Mdwnin::Keygen.stub(:generate, "hello") do
        document = subject.create(valid_data)
        document.read_only_key.must_match /^[0-9a-z]{64}$/
      end
    end
  end

  describe "before save" do
    subject {
      Mdwnin::Document.create(valid_data)
    }
    it "compiles the raw body as Markdown" do
      subject.raw_body = "New body"
      subject.save

      subject.compiled.wont_be_empty
      subject.compiled.must_match "New body"
    end

    it "does not overwrite the key" do
      old_key = subject.key.dup
      subject.raw_body = "New body"
      subject.save

      subject.key.must_equal old_key
    end
  end

  describe "validations" do
    it "is valid with a raw body" do
      document = subject.new(valid_data)

      document.must_be :valid?
    end

    it "is invalid without a raw body" do
      document = subject.new

      document.wont_be :valid?
      document.errors.keys.must_include :raw_body
    end
  end
end
