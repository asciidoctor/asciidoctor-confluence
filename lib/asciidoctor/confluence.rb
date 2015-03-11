require_relative 'confluence/version'
require_relative './page'
require_relative './confluence_api'

require 'asciidoctor'
require 'faraday'
require 'json'


module Asciidoctor
  module Confluence

    class Publisher
      SUCCESSFUL_CREATE_RESULT = 'The page has been successfully created. It is available here: '
      SUCCESSFUL_UPDATE_RESULT = 'The page has been successfully updated. It is available here: '

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
        page = Page.new @confluence_options[:space_key], @confluence_options[:title], document, @confluence_options[:page_id]
        api = ConfluenceAPI.new @confluence_options, page

        begin
          response = api.create_or_update_page @confluence_options[:update], @confluence_options[:page_id]

          response_body = JSON.parse response.body
          if response.success?
            url = response_body['_links']['base']+response_body['_links']['webui']

            if @confluence_options[:update]
              $stdout.puts SUCCESSFUL_UPDATE_RESULT + url
            else
              $stdout.puts SUCCESSFUL_CREATE_RESULT + url
            end
            return 0
          else
            action = get_action_string
            show_error action, response_body['message']
            return 1
          end
        rescue Exception => e
          show_error get_action_string, e.message
        end
        return 0
      end

      def get_action_string
        @confluence_options[:update] ? action = 'updated' : action = 'created'
        action
      end

      def show_error(action, message)
        $stderr.puts "An error occurred, the page has not been #{action} because:\n#{message}"
      end
    end
  end
end
