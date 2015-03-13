require 'asciidoctor'
require 'stringio'
require 'asciidoctor/cli'
require_relative './options'
require_relative '../confluence/invoker'

module Asciidoctor
  module Confluence

    class Invoker
      def self.invoke(args)
        begin
          orig_stdout, orig_stderr = $stdout, $stderr
          captured_stdout, captured_stderr = StringIO.new, StringIO.new
          $stdout, $stderr = captured_stdout, captured_stderr

          options = Asciidoctor::Confluence::Options.parse! args
          unless invoke_helper_or_version(args)
            publisher = Asciidoctor::Confluence::Publisher.new options
            publisher.publish
          else
            return 0
          end
        ensure
          $stderr = orig_stdout
          $stdout = orig_stderr

          $stderr.puts captured_stderr.string
          $stdout.puts captured_stdout.string
        end
      end

      def self.invoke_helper_or_version(args)
        helpers = %w(-h --help -V --version)
        args.size == 1 && helpers.include?(args[0])
      end
    end

  end
end
