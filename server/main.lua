local cache = {}
local cacheSize = 0

local MAX_CACHE_SIZE = 1024 * 1024 * 10 -- 10 MB
local GARBAGE_COLLECTOR_INTERVAL = 60000

local os_time = os.time
local math_floor = math.floor
local table_remove = table.remove

-- Hash the key
-- @param string The key
-- @return number The hashed key optimized for performance and avoid collisions
local function hash(key)
    local result = 5381
  
    for i = 1, #key do
        result = (result * 33 + string.byte(key, i)) % 2^32
    end
  
    return result
end

-- Set a key-value pair in the cache with an optional TTL
-- @param string key The cache key
-- @param any value The value to cache
-- @param number ttl The time-to-live in seconds (optional)
local function Set(key, value, ttl)
    local entry = cache[key]
    
    if entry then
        cacheSize = cacheSize - #entry.value
    end
    
    local expireAt = ttl and (os_time() + ttl) or false
    local hashedKey = math_floor(hash(key))
    
    cache[hashedKey] = {value = value, expireAt = expireAt}
    cacheSize = cacheSize + #value
  
    if cacheSize > MAX_CACHE_SIZE then
        Flush()
    end
end

-- Get a cached value by key
-- @param string key The cache key
-- @return any The cached value or nil if not found or expired
local function Get(key)
    local hashedKey = math_floor(hash(key))
    local entry = cache[hashedKey]
  
    if entry and (not entry.expireAt or os_time() < entry.expireAt) then
        return entry.value
    end
end

-- Delete a cached entry by key
-- @param string key The cache key
local function Delete(key)
    local hashedKey = math_floor(hash(key))
    local entry = cache[hashedKey]
  
    if entry then
        cacheSize = cacheSize - #entry.value
    
        cache[hashedKey] = nil
    end
end

-- Check if a key exists in the cache
-- @param string key The cache key
-- @return boolean True if the key exists, false otherwise
local function Exists(key)
    local hashedKey = math_floor(hash(key))
  
    return not not cache[hashedKey]
end

-- Flush the entire cache
local function Flush()
    cache = {}
    cacheSize = 0
end

-- Garbage collection for expired entries
local function GC()
    local now = os_time()
  
    for hashedKey, entry in pairs(cache) do
        if entry.expireAt and now >= entry.expireAt then
            cacheSize = cacheSize - #entry.value
      
            cache[hashedKey] = nil
        end
    end
end

-- Schedule garbage collection every minute
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(GARBAGE_COLLECTOR_INTERVAL)
      
        GC()
    end
end)


exports("Set", Set)
exports("Get", Get)
exports("Delete", Delete)
exports("Exists", Exists)
exports("Flush", Flush)
