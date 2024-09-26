# ImageLoader

An asynchronous image loader with cache. It fetches images asynchronously and store them in a In Memory cache.
The cache uses an LRU (Least Recently Used) eviction strategy to manage memory efficiently.

**Flow**

```mermaid
graph TD
    Client -->|Requests Image| ImageLoader
    ImageLoader -->|Checks Cache| Cache
    ImageLoader -->|Fetches Image| DataLoader
    Cache -->|LRU Eviction| EvictionStrategy
    DataLoader -->|Uses URLSession| URLSession
    ImageLoader -->|Handles Tasks| TaskManager
    Cache -->|Stores Image Data| InMemoryStorage

```

**Missed improvements**

- Extension on Image types for better usaged of imageloader
- iOS/MacOS app to test the flow, Integration tests are included.
