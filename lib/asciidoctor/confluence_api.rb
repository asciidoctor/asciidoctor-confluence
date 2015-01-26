module Asciidoctor
  module Confluence
    class ConfluenceAPI

      DEFAULT_CONTENT_TYPE = 'application/json'
      API_CONTENT = 'rest/api/content'

      attr_reader :url
      @page
      @auth

      def initialize(confluence_options, page)
        @url = build_api_content_url(confluence_options)
        @auth = confluence_options[:auth] unless confluence_options[:auth].nil?
        @page = page
      end

      def build_api_content_url(confluence_options)
        host = confluence_options[:host]
        host = host + '/' unless confluence_options[:host].end_with?('/')
        host+ API_CONTENT
      end

      def create_connection
        conn = Faraday.new do |faraday|
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end

        conn.basic_auth(@auth[:username], @auth[:password]) unless @auth.nil?
        return conn
      end

      def create_page
        conn = create_connection
        conn.post do |req|
          req.url @url
          req.headers['Content-Type'] = DEFAULT_CONTENT_TYPE
          req.body = @page.to_json
        end
      end
    end
  end
end