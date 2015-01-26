require 'asciidoctor/cli/options'
require 'stringio'
require_relative '../confluence'

module Asciidoctor
  module Confluence

    class Options < Asciidoctor::Cli::Options

      HOST_MISSING = 'FAILED: The hostname of the Confluence instance is missing'
      SPACE_KEY_MISSING = 'FAILED: The spaceKey of the Confluence instance is missing'
      TITLE_MISSING = 'FAILED: The title of the Confluence page is missing'

      def initialize(options = {})
        super options
        self[:confluence] = options[:confluence] || {}
        self[:confluence][:auth] = {} if self[:confluence][:auth].nil?
      end

      def parse!(args)
        begin
          old_stderr = $stderr
          $stderr = StringIO.new
          init_options args
          base_options = super args
          if (base_options.is_a? ::Integer) && base_options == -1
            $stderr.puts 'There are some issue with the asciidoctor command'
          end

          check_mandatory_options
        ensure
          output = $stderr.string
          $stderr = old_stderr
          $stderr.puts output
        end
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

          opts.on('--username USERNAME', 'the username used if credential are need to create the page') do |spaceKey|
            self[:confluence][:auth][:username] = spaceKey
          end

          opts.on('--password PASSWORD', 'the password used if credential are need to create the page') do |spaceKey|
            self[:confluence][:auth][:password] = spaceKey
          end

          opts.on_tail('-h', '--help', 'show this message') do
            $stdout.puts opts, "\n\n"
            Asciidoctor::Cli::Options.parse! ['-h']
            return 0
          end

        end
        opts_parser.parse! args
      end


      def check_mandatory_options
        $stderr.puts HOST_MISSING if self[:confluence][:host].nil?
        $stderr.puts SPACE_KEY_MISSING if self[:confluence][:space_key].nil?
        $stderr.puts TITLE_MISSING if self[:confluence][:title].nil?
        $stderr.string.nil_or_empty? ? 1 : 0
      end

      def self.parse! (*args)
        Options.new.parse! args.flatten
      end
    end
  end
end