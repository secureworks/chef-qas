require 'chefspec'
require 'chefspec/berkshelf'
%w( HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ).each { |e| ENV.delete(e) }
