require 'lib/rack/jsonp'
require 'jsonp_proxy_server'

use Rack::JSONP
use Rack::Config do |config|
  config['proxy.to'] = 'http://yourhost.com'
end

app = JSONPProxyServer.new

run app