module Asciidoctor
  module Confluence
    class ConfluenceAPI

      DEFAULT_CONTENT_TYPE = 'application/json'
      API_CONTENT = 'rest/api/content'
      IMAGE_PREFIX = 'img src='

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
        @host = confluence_options[:host]
        host = host + '/' unless confluence_options[:host].end_with?('/')
        host+ API_CONTENT
      end

      def with_basic_auth conn
        conn.basic_auth(@auth[:username], @auth[:password]) unless @auth.nil?
        conn
      end

      def create_connection
        conn = Faraday.new do |faraday|
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end

        with_basic_auth conn
      end

      def create_or_update_page(update=false, page_id=nil)
        if update
          if page_id.nil?
            confluence_page = find_page_by_title_and_space(@page.space_key, @page.title)
            response_body = JSON.parse confluence_page.body
            results = response_body['results']

            length = results.length

            if length == 1
              page_id = results[0]['id']
              current_revision = results[0]['version']['number']
            else
              plural = length > 0 ? 's' : ''
              raise Exception, "Error: #{length} page#{plural} entitled '#{@page.title}' found in the space '#{@page.space_key}'"
            end
          else
            confluence_page = find_page page_id
            response_body = JSON.parse confluence_page.body
            current_revision = response_body['version']['number']
          end

          update_page page_id, current_revision
        else
          create_page
        end
      end

      def create_page
        conn = create_connection
        conn.post do |req|
          req.url @url
          req.headers['Content-Type'] = DEFAULT_CONTENT_TYPE
          req.body = @page.to_json
        end
      end

      def upload_image(page_id, file_name)
        conn = Faraday.new(url: @host, headers: {'X-Atlassian-Token'=> "nocheck"}) do |f|
          f.request :multipart
          f.request :url_encoded
          f.adapter :net_http
        end
        with_basic_auth(conn).post "/#{API_CONTENT}/#{page_id}/child/attachment",
          { file: Faraday::UploadIO.new(file_name, 'image/png') }
      end

      def each_uploaded_image(page_id)
        @page.document.scan(/#{IMAGE_PREFIX}"([^\\\/"]+)"/).flatten.map do |file_name|
          upload_image(page_id, file_name)
          file_name
        end
      end

      def update_page(page_id, current_revision)
        @page.revision = current_revision.to_i+1

        each_uploaded_image(page_id).each do |file_name|
          @page.document.gsub!("#{IMAGE_PREFIX}\"#{file_name}\"", "#{IMAGE_PREFIX}\"/download/attachments/#{page_id}/#{file_name}?api=v2\"")
        end

        conn = create_connection
        conn.put do |req|
          req.url "#{@url}/#{page_id}"
          req.headers['Content-Type'] = DEFAULT_CONTENT_TYPE
          req.body = @page.to_json
        end
      end

      def find_page_by_title_and_space(space_key, title)
        conn = create_connection
        conn.get do |req|
          req.url "#{@url}/?spaceKey=#{space_key}&title=#{title}&expand=version"
          req.headers['Content-Type'] = DEFAULT_CONTENT_TYPE
        end
      end

      def find_page(page_id)
        conn = create_connection
        conn.get do |req|
          req.url "#{@url}/#{page_id}"
          req.headers['Content-Type'] = DEFAULT_CONTENT_TYPE
        end
      end
    end
  end
end
