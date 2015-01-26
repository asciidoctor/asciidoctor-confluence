require 'test-unit'
require 'webmock/test_unit'
require 'asciidoctor/confluence_api'
require 'asciidoctor/confluence'

#require 'asciidoctor-confluence/lib/asciidoctor/confluence'

class PublisherTests < Test::Unit::TestCase
  def setup
    @orig_stderr = $stderr
    $stderr = StringIO.new

    @orig_stdout = $stdout
    $stdout = StringIO.new
  end

  def teardown
    $stderr = @orig_stderr
    @orig_stderr
    $stdout = @orig_stdout
    @orig_stdout = nil
  end

  def test_successful_publishing
    test_url = 'http://username:password@confluence.domain/'+Asciidoctor::Confluence::ConfluenceAPI::API_CONTENT
    host = 'http://confluence.domain/'
    webui = 'webui'
    response_body = JSON.generate ( {
        '_links' => {
            'base' => host,
            'webui' => webui
        }
    })
    stub_request(:post, test_url).to_return(:status => 200, :body => response_body)
    auth = {:username => 'username', :password => 'password'}
    options = {:confluence => {:auth => auth, :host => host, :title => 'Asciidoctor Page'}, :input_files => ['test.adoc']}
    publisher = Asciidoctor::Confluence::Publisher.new options
    publish_result = publisher.publish
    assert_equal 0, publish_result
    assert_true $stdout.string.include? Asciidoctor::Confluence::Publisher::SUCCESSFUL_RESULT+host+webui
  end

  def test_failing_publishing
    test_url = 'http://username:password@confluence.domain/'+Asciidoctor::Confluence::ConfluenceAPI::API_CONTENT
    host = 'http://confluence.domain/'
    error_message = 'The page already exists'
    response_body = JSON.generate ( {
        'message' => error_message
    })
    stub_request(:post, test_url).to_return(:status => 400, :body => response_body)
    auth = {:username => 'username', :password => 'password'}
    options = {:confluence => {:auth => auth, :host => host, :title => 'Asciidoctor Page'}, :input_files => ['test.adoc']}
    publisher = Asciidoctor::Confluence::Publisher.new options
    publish_result = publisher.publish
    assert_equal 1, publish_result
    assert_true $stderr.string.include? error_message
  end
end