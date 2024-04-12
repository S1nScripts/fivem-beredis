# beredis
beredis is a high-performance caching library written in Lua for FiveM. It provides a simple and efficient solution for storing and retrieving data in memory, optimizing the performance of your FiveM scripts.

## Features
In-memory storage of key-value pairs
Support for expiration durations (TTL) for cache entries
Configurable maximum cache size for controlled memory usage
Hash functions for fast lookups
Automatic garbage collection to remove expired entries
Simple and intuitive API for easy integration into your FiveM scripts

## Usage

```lua
-- Import the beredis library
local beredis = exports['beredis']

-- Set a value in the cache with an expiration duration (TTL)
beredis:Set('my_key', 'my_value', 3600) -- Expires in 1 hour

-- Get a value from the cache
local value = beredis:Get('my_key')
print(value) -- Output: my_value

-- Check if a key exists in the cache
local exists = beredis:Exists('my_key')
print(exists) -- Output: true

-- Delete an entry from the cache
beredis:Delete('my_key')

-- Flush the entire cache
beredis:Flush()
```

