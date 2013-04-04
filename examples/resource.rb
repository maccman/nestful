require 'nestful'

class Charge < Nestful::Resource
  url 'https://api.stripe.com/v1/charges'
  options :auth_type => :bearer, :password => 'sk_test_mkGsLqEW6SLnZa487HYfJVLf'
end