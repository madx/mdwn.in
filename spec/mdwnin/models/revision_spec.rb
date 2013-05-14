# encoding: utf-8

require 'spec_helper'

require 'mdwnin/models/revision'

class Mdwnin::RevisionSpec < SequelSpec
  subject { Mdwnin::Revision }

  describe 'validations' do
    let(:valid_data) {
      { raw_body: "Hello world" }
    }

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
end
