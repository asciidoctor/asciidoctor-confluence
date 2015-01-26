require 'asciidoctor'
require 'asciidoctor/cli'
require_relative './options'
require_relative '../confluence/invoker'

module Asciidoctor
  module Confluence

    class Invoker
      def self.invoke(args)
        options = Asciidoctor::Confluence::Options.parse! args #['--host', 'http://192.168.59.103:8090/', '--spaceKey', 'AS', '--title', 'Asciidoctor is awesome', '--username', 'admin', '--password', 'admin', 'test.adoc']
        publisher = Asciidoctor::Confluence::Publisher.new options
        publisher.publish
      end
    end

  end
end
