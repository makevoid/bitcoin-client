# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

bitcoin-client is a Ruby gem that provides a complete interface to the Bitcoin JSON-RPC API. It's a fork maintained by @makevoid of the original sinisterchipmunk/bitcoin-client. The library supports all Bitcoin daemon API methods and provides three different usage patterns: functional, object-oriented, and DSL-based.

## Development Commands

### Running Tests
```bash
# Run all specs (default rake task)
rake
# or
rake spec
# or
rspec

# Run a specific spec file
rspec spec/lib/bitcoin-client/client_spec.rb

# Run a specific test
rspec spec/lib/bitcoin-client/client_spec.rb:10
```

### Building the Gem
```bash
rake build
```

### Installing Locally
```bash
gem build bitcoin-client.gemspec
gem install ./bitcoin-client-<version>.gem
```

## Architecture Overview

### Core Components

1. **BitcoinClient::Client** (`lib/bitcoin-client/client.rb`)
   - Main client class that wraps the API
   - Implements all Bitcoin RPC methods (getbalance, sendtoaddress, etc.)
   - Delegates to BitcoinClient::API for actual requests
   - Provides Ruby-friendly method aliases (e.g., `balance` for `getbalance`)

2. **BitcoinClient::API** (`lib/bitcoin-client/api.rb`)
   - Handles connection configuration (host, port, SSL, credentials)
   - Implements optional Redis caching layer for read-only operations
   - Caching is opt-in via `cache: true` option
   - CACHABLE_CALLS constant defines which RPC methods can be cached (30 second TTL)
   - Delegates to RPC for HTTP communication

3. **BitcoinClient::RPC** (`lib/bitcoin-client/rpc.rb`)
   - Low-level HTTP JSON-RPC transport layer
   - Uses rest-client for HTTP communication
   - Constructs service URLs with authentication
   - Handles JSON parsing and error responses

4. **BitcoinClient::Request** (`lib/bitcoin-client/request.rb`)
   - Encapsulates RPC request data
   - Handles nil parameter cleanup (Bitcoin rejects null values)
   - Converts to JSON-RPC format

5. **BitcoinClient::DSL** (`lib/bitcoin-client/dsl.rb`)
   - Provides module for DSL-style usage
   - Allows include/extend for convenience methods
   - Mirrors all Client methods

### Three Usage Patterns

The library supports three different ways to interact with Bitcoin:

1. **Functional**: `BitcoinClient('user', 'pass').balance`
2. **Object-Oriented**: `client = BitcoinClient::Client.new('user', 'pass'); client.balance`
3. **DSL**: `include BitcoinClient; username 'user'; password 'pass'; balance`

### Connection Options

The API supports customizing:
- `host`: Bitcoin daemon host (default: 'localhost')
- `port`: Bitcoin daemon port (default: 8332)
- `ssl`: Use HTTPS (default: false)
- `cache`: Enable Redis caching (default: false)
- `redis`: Custom Redis instance for caching

### Testing Strategy

Tests use FakeWeb to mock HTTP requests. Fixture files in `spec/fixtures/` contain sample JSON-RPC responses for various Bitcoin commands. The test suite:
- Verifies proper request formatting
- Validates response parsing
- Tests error handling
- Ensures nil parameter cleanup works correctly

### Error Handling

Custom error class `BitcoinClient::Errors::RPCError` is raised for:
- JSON parsing failures (includes full request/response context)
- Bitcoin daemon errors (passes through the error from the response)

## Important Notes

- The library handles nil parameters specially: trailing nil params are dropped since Bitcoin rejects null values
- Time values in responses (like block times) are automatically converted to Ruby Time objects (UTC)
- All Bitcoin RPC method names are preserved exactly as documented on the Bitcoin wiki
- Method aliases are provided in both Client and DSL modules for Ruby-style naming
