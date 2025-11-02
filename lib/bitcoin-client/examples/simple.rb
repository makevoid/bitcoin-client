#!/usr/bin/env ruby

# Simple example of connecting to Bitcoin Core and retrieving blockchain info
# This replicates: bitcoin-cli -rpcuser=btcuser -rpcpassword=*** getblockchaininfo

require 'bundler/setup'
require 'bitcoin-client'

# Connection details
HOST = '46.4.70.232'
PORT = 8332
USERNAME = 'btcuser'
PASSWORD = File.read(File.expand_path('~/.bitcoin-core-rpc-password')).strip

# Create a client instance (cache: false to disable Redis caching)
client = BitcoinClient::Client.new(USERNAME, PASSWORD, host: HOST, port: PORT, cache: false)

# Get blockchain info
puts "Connecting to Bitcoin Core at #{HOST}:#{PORT}..."
puts

begin
  info = client.getblockchaininfo

  puts "Blockchain Information:"
  puts "=" * 50
  puts "Chain: #{info['chain']}"
  puts "Blocks: #{info['blocks']}"
  puts "Headers: #{info['headers']}"
  puts "Best Block Hash: #{info['bestblockhash']}"
  puts "Difficulty: #{info['difficulty']}"
  puts "Verification Progress: #{(info['verificationprogress'].to_f * 100).round(2)}%"
  puts "Chain Work: #{info['chainwork']}"
  puts
  puts "Full Response:"
  puts JSON.pretty_generate(info)

rescue BitcoinClient::Errors::RPCError => e
  puts "RPC Error: #{e.message}"
  exit 1
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  exit 1
end
