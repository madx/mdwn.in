# encoding: utf-8

require 'bundler/setup'

require 'minitest/autorun'
require 'rack/test'

lib_dir = File.expand_path('../lib', File.dirname(__FILE__))
$:.unshift(lib_dir) unless $:.include?(lib_dir)
