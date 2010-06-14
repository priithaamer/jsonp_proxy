require 'net/http'
require 'uri'

class JSONPProxyServer
  def call(env)
    source_request = Rack::Request.new(env)
    
    uri = URI.parse([env['proxy.to'], source_request.fullpath] * '')
    
    headers = extract_http_request_headers(source_request.env)
    headers['HOST'] = uri.host
    
    http = Net::HTTP.new(uri.host, uri.port)
    get = Net::HTTP::Get.new(uri.request_uri)
    get.initialize_http_header(headers)
    response = http.request(get)
    
    [response.code, {'Content-Type' => response['Content-Type']}, response.body]
  end
  
  private
  
  def extract_http_request_headers(env)
    headers = env.reject do |k, v|
      !(/^HTTP_[A-Z_]+$/ === k)
    end.map do |k, v|
      [k.sub(/^HTTP_/, ""), v]
    end.inject(Rack::Utils::HeaderHash.new) do |hash, k_v|
      k, v = k_v
      hash[k] = v
      hash
    end
  
    x_forwarded_for = (headers["X-Forwarded-For"].to_s.split(/, +/) << env["REMOTE_ADDR"]).join(", ")
  
    headers.merge!("X-Forwarded-For" =>  x_forwarded_for)
  end
end