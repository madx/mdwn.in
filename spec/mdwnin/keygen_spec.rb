# encoding: utf-8

require 'spec_helper'

require 'mdwnin/keygen'

describe Mdwnin::Keygen do
  subject { Mdwnin::Keygen }
  let(:time) { Time.at(42) }

  describe ".generate" do
    it "returns a non empty string" do
      subject.generate.wont_be_empty
    end

    it "is comprised of lowercase letters, numbers, and one dot" do
      key = subject.generate

      key.must_match /^[a-z0-9.]+$/
      key.count('.').must_equal 1
    end

    it "takes an optional base time" do
      key = subject.generate(time)

      key.must_match time.usec.to_s(36)
    end

    it "does not return the same key for two runs atthe same time" do
      key1 = subject.generate(time)
      key2 = subject.generate(time)

      key1.wont_equal key2
    end
  end
end
