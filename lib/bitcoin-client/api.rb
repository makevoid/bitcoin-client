class BitcoinClient::API
  attr_reader :options
  attr_reader :params

  def user; options[:user]; end
  def pass; options[:pass]; end
  def host; options[:host]; end
  def port; options[:port]; end
  def ssl;  options[:ssl];  end
  def ssl?; options[:ssl];  end
  def user=(a); options[:user] = a; end
  def pass=(a); options[:pass] = a; end
  def host=(a); options[:host] = a; end
  def port=(a); options[:port] = a; end
  def ssl=(a);  options[:ssl]  = a; end

  def initialize(options = {})
    @options = {
      host:  'localhost',
      port:  8332,
      ssl:   false,
      cache: false,
    }.merge(options)

    if @options[:cache]
      @redis = @options[:redis] || Redis.new
    end
  end

  def to_hash
    @options.dup
  end

  CACHABLE_CALLS = %w(
    getaddednodeinfo
    getnetworkhashps
    getreceivedbyaddress
    getreceivedbyaccount
    listreceivedbyaddress
    listreceivedbyaccount
    getbalance
    getblockhash
    listtransactions
    listaccounts
    getblocktemplate
    listsinceblock
    listunspent
    getblock
    getblockheader
    gettransaction
    getrawtransaction
    gettxout
    gettxoutproof
    getrawmempool
    estimatefee
    estimatepriority
    getwalletinfo
    getnettotals
    getblockchaininfo
    getblockcount
    getinfo
  )

  def request(service_name, *params)
    if options[:cache]
      cache_key = ([service_name] + params).flatten.join "_"
    end

    if options[:cache] && @redis.exists(cache_key) && CACHABLE_CALLS.include?(service_name)
      # puts "FROM CACHE: #{cache_key}" # TODO: debug
      val = @redis.get cache_key
      val = JSON.load val
      val
    else
      cache_expire_sec = 30
      req  = BitcoinClient::Request.new service_name, params
      resp = BitcoinClient::RPC.new(to_hash).dispatch req
      @redis.setex cache_key, cache_expire_sec, resp.to_json
      resp
    end
  end

end
