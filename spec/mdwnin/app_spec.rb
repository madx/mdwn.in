# encoding: utf-8

require 'spec_helper'
require 'rack/test'

require 'mdwnin/app'

describe Mdwnin::App do
  include Rack::Test::Methods

  def app
    Mdwnin::App
  end

  describe 'GET /' do
    it 'is ok' do
      get '/'

      last_response.must_be :ok?
    end
  end


end
