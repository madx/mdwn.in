
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
end
