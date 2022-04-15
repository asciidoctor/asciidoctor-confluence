require 'asciidoctor/cli/options'
require_relative '../confluence'

module Asciidoctor
  module Confluence

    class Options < Asciidoctor::Cli::Options

      HOST_MISSING = 'FAILED: The hostname of the Confluence instance is missing'
      SPACE_KEY_MISSING = 'FAILED: The spaceKey of the Confluence instance is missing'
      TITLE_MISSING = 'FAILED: The title of the Confluence page is missing'

      def initialize(options = {})
        super options
        self[:confluence] = options[:confluence] || {:update => false}
        self[:confluence][:auth] = {} if self[:confluence][:auth].nil?
      end

      def parse!(args)
          init_options args
          unless args.empty?
            base_options = super args
            if (base_options.is_a? ::Integer) && base_options == -1
              $stderr.puts 'There are some issue with the asciidoctor command'
            end
          end

          self
      end

      def init_options(args)
        opts_parser = ::OptionParser.new do |opts|
          opts.banner = <<-EOS
Usage: asciidoctor-confluence --host HOSTNAME --spaceKey SPACEKEY --title TITLE [ASCIIDOCTOR OPTIONS]...  FILE...
          EOS

          opts.on('--host HOST', 'the hostname of the Confluence instance ') do |host|
            self[:confluence][:host] = host
          end

          opts.on('--spaceKey SPACEKEY', 'the Confluence space within the page will be created') do |spaceKey|
            self[:confluence][:space_key] = spaceKey
          end

          opts.on('--title TITLE', 'the title of the Confluence page') do |title|
            self[:confluence][:title] = title
          end

          opts.on('--pageid PAGEID', 'the id of the page to update') do |page_id|
            self[:confluence][:page_id] = page_id
            end

          opts.on('--update', 'indicate that the page must be updated instead of created') do
            self[:confluence][:update] = true
          end

          opts.on('--username USERNAME', 'the username used if credential are need to create the page') do |spaceKey|
            self[:confluence][:auth][:username] = spaceKey
          end

          opts.on('--password PASSWORD', 'the password used if credential are need to create the page') do |spaceKey|
            self[:confluence][:auth][:password] = spaceKey
          end
          
          opts.on('--bearerAuth TOKEN', 'the token used if Bearer Authentication is required to create the page') do |token|
            self[:confluence][:auth][:token] = token
          end

          opts.on_tail('-h', '--help', 'Show the full helper (including Asciidoctor helper)') do
            $stdout.puts opts, "\n\n"
            return Asciidoctor::Cli::Options.parse! ['-h']
          end

          opts.on_tail('-V', '--version', 'display the version and runtime environment (or -v if no other flags or arguments)') do
            $stdout.puts "Asciidoctor-confluence v#{Asciidoctor::Confluence::VERSION}\n"
            return Asciidoctor::Cli::Options.parse! ['-V']
          end

        end

        opts_parser.parse! args
        check_mandatory_options
      end


      def check_mandatory_options
        raise HOST_MISSING if self[:confluence][:host].nil?
        raise SPACE_KEY_MISSING if self[:confluence][:space_key].nil?
        raise TITLE_MISSING if self[:confluence][:title].nil?
      end

      def self.parse! (*args)
        Options.new.parse! args.flatten
      end
    end
  end
end