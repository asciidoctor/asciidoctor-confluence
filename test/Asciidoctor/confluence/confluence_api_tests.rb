require 'test/unit'
require 'asciidoctor/confluence_api'

class ConfluenceAPITests < Test::Unit::TestCase
  def test_build_content_api_without_ending_slash
    url = 'http://confluence.mydomain'
    api = Asciidoctor::Confluence::ConfluenceAPI.new({:host => url}, nil)
    assert_equal url+'/'+Asciidoctor::Confluence::ConfluenceAPI::API_CONTENT, api.url
    end

  def test_build_content_api_with_ending_slash
    url = 'http://confluence.mydomain/'
    api = Asciidoctor::Confluence::ConfluenceAPI.new({:host => url}, nil)
    assert_equal url+Asciidoctor::Confluence::ConfluenceAPI::API_CONTENT, api.url
  end


end