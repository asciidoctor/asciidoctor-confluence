require 'test/unit'
require 'asciidoctor/confluence/options'

class OptionsTests < Test::Unit::TestCase
  def setup
    @orig_stderr = $stderr
    $stderr = StringIO.new
  end

  def teardown
    $stderr = @orig_stderr
    @orig_stderr = nil
  end

  def test_init_options
    options = Asciidoctor::Confluence::Options.new
    host = 'http://hostname'
    space_key = 'key'
    title = 'title'
    username = 'username'
    password = 'pass'
    file_name = 'file.adoc'
    base_options = options.init_options ['--host', host, '--spaceKey', space_key, '--title', title, '--username', username, '--password', password, file_name]

    assert_equal 1, base_options.size
    assert_equal file_name, base_options[0]
    assert_equal host, options[:confluence][:host]
    assert_equal space_key, options[:confluence][:space_key]
    assert_equal title, options[:confluence][:title]
    assert_equal username, options[:confluence][:auth][:username]
    assert_equal password, options[:confluence][:auth][:password]
  end

  def test_init_options_with_token
    options = Asciidoctor::Confluence::Options.new
    token = 'sometoken'
    options.init_options ['--host', 'http://hostname', '--spaceKey', 'key', '--title', 'title', '--bearerAuth', token, 'file.adoc']

    assert_equal token, options[:confluence][:auth][:token]
  end
  
  def test_with_full_options
    args = {:confluence => {:host => 'http://hostname/', :space_key => 'TEST_KEY', :title =>'Test title'}}
    options = Asciidoctor::Confluence::Options.new args
    res = options.check_mandatory_options
    assert_equal 1, res
    assert_true $stderr.string.nil_or_empty?

  end
  
  def test_host_not_present
    options = Asciidoctor::Confluence::Options.new
    res = options.check_mandatory_options
    assert_equal 0, res
    assert_true($stderr.string.include? Asciidoctor::Confluence::Options::HOST_MISSING)
  end

  def test_space_key_not_present
    args = {:confluence => {:host => 'http://hostname/'}}
    options = Asciidoctor::Confluence::Options.new args
    res = options.check_mandatory_options
    assert_equal 0, res
    assert_true($stderr.string.include? Asciidoctor::Confluence::Options::SPACE_KEY_MISSING)
  end

  def test_title_not_present
    args = {:confluence => {:host => 'http://hostname/', :space_key => 'TEST_KEY'}}
    options = Asciidoctor::Confluence::Options.new args
    res = options.check_mandatory_options
    assert_equal 0, res
    assert_true($stderr.string.include? Asciidoctor::Confluence::Options::TITLE_MISSING)
  end
end