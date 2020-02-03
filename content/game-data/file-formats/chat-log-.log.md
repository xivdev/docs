---
description: File structure for chat logs saved to FFXIV_CHR<content id>/log/*.log
---

# Chat Log \(.log\)

```cpp
struct LogBufferHdr
{
    uint32_t contentSize;
    uint32_t fileSize;
    uint32_t* offsetEntries;
};

struct LogEntry
{
    time_t timestamp;
    uint16_t eventType; // chat message kind?
    uint16_t unknown;
    char* message; // inline str
};
```

You can read entries like so:

```cpp
void read( uint8_t* data )
{
    auto hdr = reintepret_cast< LogBufferHdr* >( data );
    
    std::vector< LogEntry* > entries;
    auto offsetEntriesCount = hdr->fileSize - hdr->contentSize;
    
    for( auto i = 0; i < offsetEntriesCount; i++ )
    {
        auto offset = hdr->offsetEntries[ i ];
        auto entry = reintepret_cast< LogEntry* >( data + offset );
        entries.push_back( entry );
    }
}
```

