# encoding: utf-8

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'

require 'minitest/autorun'
require 'rack/test'
require 'pry'

require_relative '../config/environment'

lib_dir = File.expand_path('../lib', File.dirname(__FILE__))
$:.unshift(lib_dir) unless $:.include?(lib_dir)

class SequelSpec < MiniTest::Spec
  def run(*args, &block)
    result = nil
    Sequel::Model.db.transaction(:rollback=>:always){result = super}
    result
  end
end
