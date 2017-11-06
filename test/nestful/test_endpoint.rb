require 'test_helper'

class TestEndpoint < MiniTest::Unit::TestCase
  def test_join
    endpoint = Nestful::Endpoint['http://example.com']['charges'][1]
    assert_equal 'http://example.com/charges/1', endpoint.url
  end

  def test_get
    stub_request(:any, 'http://example.com/charges?limit=10')
    endpoint = Nestful::Endpoint['http://example.com']['charges'].get(:limit => 10)
    assert_requested(:get, 'http://example.com/charges?limit=10')
  end

  def test_post
    stub_request(:any, 'http://example.com/charges')
    endpoint = Nestful::Endpoint['http://example.com']['charges'].post
    assert_requested(:post, 'http://example.com/charges')
  end
end
