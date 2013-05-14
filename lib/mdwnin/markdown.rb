# encoding: utf-8

require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

module Mdwnin
  class Markdown
    MARKDOWN_OPTIONS = {
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      strikethrough: true,
      autolink: true
    }.freeze
    private_constant :MARKDOWN_OPTIONS

    def self.render(source)
      renderer = Redcarpet::Markdown.new(Renderer, MARKDOWN_OPTIONS)

      renderer.render(source)
    end

    class Renderer < Redcarpet::Render::HTML
      include Rouge::Plugins::Redcarpet

      def initialize(options={})
        super(options.merge(with_toc_data: true))
      end
    end
  end
end
