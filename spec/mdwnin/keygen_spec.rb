# encoding: utf-8

require 'spec_helper'

require 'mdwnin/keygen'

describe Mdwnin::Keygen do
  subject { Mdwnin::Keygen }

  describe ".generate" do
    it "returns a non empty string" do
      subject.generate.wont_be_empty
    end

    it "is comprised of lowercase letters, numbers, and one dot" do
      key = subject.generate

      key.must_match /^[a-z0-9.]+$/
      key.count('.').must_equal 1
    end
  end
end
