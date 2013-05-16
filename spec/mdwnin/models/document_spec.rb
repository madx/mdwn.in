
# encoding: utf-8

require 'spec_helper'

require 'mdwnin/models/document'

class Mdwnin::DocumentSpec < SequelSpec
  subject { Mdwnin::Document }

  describe "before save" do
    it "generates an unique key with the keygen" do
      Mdwnin::Keygen.stub(:generate, "hello") do
        document = subject.create
        document.key.must_equal "hello"
      end
    end
  end

  describe "associations" do
    subject { Mdwnin::Document.create }

    it "has no revisions upon create" do
      subject.revisions.must_be_empty
    end

    it "may add additional revisions" do
      subject.add_revision(raw_body: "Hello world")

      subject.revisions.wont_be_empty
    end
  end
end
