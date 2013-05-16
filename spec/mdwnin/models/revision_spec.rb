# encoding: utf-8

require 'spec_helper'

require 'mdwnin/models/revision'

class Mdwnin::RevisionSpec < SequelSpec
  subject { Mdwnin::Revision }
  let(:valid_data) {
    { raw_body: "Hello world" }
  }

  describe "validations" do
    it "is valid with a raw body" do
      rev = subject.new(valid_data)

      rev.must_be :valid?
    end

    it "is invalid without a raw body" do
      rev = subject.new

      rev.wont_be :valid?
      rev.errors.keys.must_include :raw_body
    end
  end

  describe "before save" do
    it "compiles the raw body as Markdown" do
      rev = subject.create(valid_data)

      rev.compiled.wont_be_empty
      rev.compiled.must_match valid_data[:raw_body]
    end
  end

  describe "associations" do
    it "may have an associated document" do
      doc = Mdwnin::Document.create
      rev = Mdwnin::Revision.new(valid_data)

      doc.add_revision(rev)

      rev.document.wont_be_nil
    end
  end
end
