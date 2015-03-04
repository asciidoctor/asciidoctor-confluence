require_relative 'confluence/version'
require_relative './page'
require_relative './confluence_api'

require 'asciidoctor'
require 'faraday'
require 'json'


module Asciidoctor
  module Confluence

    class Publisher
      SUCCESSFUL_RESULT = 'The page has been successfully created. It is available here: '

      def initialize(options)
        @confluence_options = options[:confluence]
        @asciidoctor_options = options
        @asciidoctor_options[:to_file] = false
        @asciidoctor_options[:header_footer] = false

        if (options[:input_files].is_a? ::Array) && (options[:input_files].length == 1)
          @input_file = options[:input_files][0]
        else
          @input_file = options[:input_files]
        end
      end

      def publish
        document = Asciidoctor.convert_file @input_file, @asciidoctor_options
        page = Page.new @confluence_options[:space_key], @confluence_options[:title], document
        api = ConfluenceAPI.new @confluence_options, page
        response = api.create_page

        response_body = JSON.parse response.body
        if response.success?
          url = response_body['_links']['base']+response_body['_links']['webui']

          $stdout.puts SUCCESSFUL_RESULT + url
          0
        else
          $stderr.puts response_body['message']
          1
        end
      end
    end
  end
end
