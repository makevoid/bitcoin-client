# Bitcoin Client Examples

This directory contains examples demonstrating how to use the bitcoin-client library.

## Setup

First, install the dependencies:

```bash
cd lib/bitcoin-client/examples
bundle install
```

## Running Examples

### simple.rb

Connects to a Bitcoin Core node and retrieves blockchain information.

```bash
ruby simple.rb
```

This example demonstrates:
- Creating a Bitcoin client instance
- Connecting to a remote Bitcoin Core node
- Calling the `getblockchaininfo` RPC method
- Handling errors properly
- Displaying formatted output

The example connects to a configured Bitcoin Core node and displays information about the blockchain including block height, difficulty, chain work, and verification progress.
