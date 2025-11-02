#!/usr/bin/env ruby

# Example of broadcasting a signed raw transaction to Bitcoin Core
# Usage: ruby broadcast_transaction.rb <signed_hex_transaction>
# This replicates: bitcoin-cli -rpcuser=btcuser -rpcpassword=*** sendrawtransaction <hex>

require 'bundler/setup'
require 'bitcoin-client'

# Check for command-line argument
if ARGV.empty?
  puts "Usage: #{$0} <signed_hex_transaction>"
  puts
  puts "Example:"
  puts "  #{$0} 0200000001abc123..."
  puts
  puts "The transaction must be a fully signed raw transaction in hexadecimal format."
  exit 1
end

signed_tx_hex = ARGV[0]

# Validate hex format (basic check)
unless signed_tx_hex.match?(/^[0-9a-fA-F]+$/)
  puts "Error: Invalid transaction format. Must be hexadecimal."
  exit 1
end

# Connection details
HOST = '46.4.70.232'
PORT = 8332
USERNAME = 'btcuser'
PASSWORD = File.read(File.expand_path('~/.bitcoin-core-rpc-password')).strip

# Create a client instance (cache: false to disable Redis caching)
client = BitcoinClient::Client.new(USERNAME, PASSWORD, host: HOST, port: PORT, cache: false)

puts "Connecting to Bitcoin Core at #{HOST}:#{PORT}..."
puts "Transaction size: #{signed_tx_hex.length / 2} bytes (#{signed_tx_hex.length} hex chars)"
puts

begin
  # Broadcast the transaction
  txid = client.sendrawtransaction(signed_tx_hex)

  puts "Transaction Broadcast Successful!"
  puts "=" * 50
  puts "Transaction ID (txid): #{txid}"
  puts
  puts "You can track this transaction using:"
  puts "  bitcoin-cli -rpcuser=#{USERNAME} gettransaction #{txid}"
  puts "  or check a block explorer for txid: #{txid}"

rescue BitcoinClient::Errors::RPCError => e
  puts "RPC Error: Failed to broadcast transaction"
  puts "=" * 50
  puts "Error message: #{e.message}"
  puts
  puts "Common reasons for failure:"
  puts "  - Transaction already in blockchain or mempool"
  puts "  - Invalid transaction format or signature"
  puts "  - Insufficient fees"
  puts "  - Double-spend detected"
  puts "  - Missing or already spent inputs"
  exit 1
rescue StandardError => e
  puts "Error: #{e.class} - #{e.message}"
  exit 1
end
