require 'rest_client'

class BitcoinClient::RPC
  def initialize(options)
    @user, @pass = options[:user], options[:pass]
    @host, @port = options[:host], options[:port]
    @ssl = options[:ssl]
  end

  def credentials
    if @user
      "#{@user}:#{@pass}"
    else
      nil
    end
  end

  def service_url
    url = @ssl ? "https://" : "http://"
    url.concat "#{credentials}@" if c = credentials
    url.concat "#{@host}:#{@port}"
    url
  end

  def dispatch(request)
    RestClient.post(service_url, request.to_post_data, content_type: :json) do |respdata, req, result|
      response = begin
        JSON.parse respdata
      rescue JSON::ParserError => e
        raise BitcoinClient::Errors::RPCError, "JSON parse error, got invalid response: '#{respdata}' - request_url: '#{service_url}', post_data: '#{request.to_post_data}' - exception: #{e.message}"
      end
      raise BitcoinClient::Errors::RPCError, response['error'] if response['error']
      response['result']
    end
  end

  private
  def symbolize_keys(hash)
    case hash
    when Hash
      hash.inject({}) do |result, (key, value)|
        key = key.to_sym if key.kind_of?(String)
        value = symbolize_keys(value)
        result[key] = value
        result
      end
    when Array
      hash.collect do |ele|
        symbolize_keys(ele)
      end
    else
      hash
    end
  end
end
