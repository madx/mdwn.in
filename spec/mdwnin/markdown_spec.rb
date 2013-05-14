# encoding: utf-8

require 'spec_helper'

require 'mdwnin/markdown'

describe Mdwnin::Markdown do
  subject { Mdwnin::Markdown }

  it "provides a Mardown parser" do
    subject.render("Hello").must_match("<p>Hello</p>")
  end

  it "enables fenced code blocks" do
    subject.render("``` ruby\nHello\n```").must_match("<pre class=\"")
  end

  it "disables intra-emphasis" do
    subject.render("foo_bar_baz").wont_match("<em>")
  end

  it "enables strikethrough" do
    subject.render("~~deleted~~").must_match("<del>")
  end

  it "enables autolinking" do
    subject.render("http://example.com/").must_match("<a")
  end

  it "enables syntax highlighting" do
    subject.render("``` ruby\nHello\n```").must_match("highlight")
  end

  it "enables TOC data" do
    subject.render("# Hello").must_match("toc_0")
  end
end
