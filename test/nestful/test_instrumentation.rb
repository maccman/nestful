require 'minitest/autorun'
require 'webmock/minitest'
require 'nestful'

WebMock.disable_net_connect!

class TestInstrumentation < MiniTest::Test
  class TestInstrumentor
    def self.reset!
      @events = []
    end

    def self.events
      @events
    end

    def self.instrument(event, *args)
      @events << [event, *args]
      yield if block_given?
    end
  end

  class InstrumentedResource < Nestful::Resource
    endpoint 'http://example.com'
    path '/v1/tokens'
    defaults instrumentor: TestInstrumentor
  end

  def setup
    stub_request(:any, 'http://example.com/v1/tokens')

    TestInstrumentor.reset!
  end

  def test_request
    InstrumentedResource.get

    event = TestInstrumentor.events.first

    assert_equal('request.nestful', event[0])
    assert_equal('example.com', event[1][:domain])
    assert_equal(:get, event[1][:method])
    assert_equal('/v1/tokens', event[1][:path])
  end

  def test_response
    InstrumentedResource.get

    event = TestInstrumentor.events.last

    assert_equal('response.nestful', event[0])
    assert_equal('example.com', event[1][:domain])
    assert_equal(:get, event[1][:method])
    assert_equal('/v1/tokens', event[1][:path])
  end

  def test_error
    stub_request(:any, 'http://example.com/v1/tokens').to_return(status: 500)

    begin
      InstrumentedResource.get
    rescue Nestful::Error
    end

    TestInstrumentor.events.shift

    event = TestInstrumentor.events.shift
    assert_equal('response.nestful', event[0])
    assert_equal(500, event[1][:code])

    event = TestInstrumentor.events.shift
    assert_equal('error.nestful', event[0])
    assert_equal('example.com', event[1][:domain])
    assert_equal(:get, event[1][:method])
    assert_equal('/v1/tokens', event[1][:path])
  end
end
