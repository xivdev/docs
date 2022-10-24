---
description: Game packet structures
---

# Packet Structure

Game packets are composed of 3 distinct parts, the packet header, the segment header and a \(sometimes\) optional IPC header.

{% hint style="info" %}
While 'IPC' is incorrect terminology given the usage, SE calls it IPC so the naming has been preserved.
{% endhint %}

## Packet Header

```cpp
struct FFXIVARR_PACKET_HEADER
{
  uint64_t magic[2];
  uint64_t timestamp;
  uint32_t size;
  uint16_t connectionType;
  uint16_t segmentCount;
  uint8_t unknown_20;
  uint8_t isCompressed;
  uint32_t unknown_24;
};
```

| Field            | Description                                                                                                                                                                                                         |
| :---             | :---                                                                                                                                                                                                                |
| `magic`          | A magic value that identifies a packet.<br><br>This is `FF14ARR` if you read it both in its hexadecimal and ASCII representation at the same time.                                                                  |
| `timestamp`      | The number of milliseconds since the unix epoch when the packet was sent.                                                                                                                                           |
| `size`           | The size of the entire packet including its segments and data.                                                                                                                                                      |
| `connectionType` | The connection type. This will be 1 for zone channel connections and 2 for chat.<br><br>This is only sent on the initial connection now, previously this was sent with every packet but that is no longer the case. |
| `unknown_20`     | Alignment, most likely.                                                                                                                                                                                             |
| `isCompressed`   | Whether the segments + remaining data is compressed. The header is always uncompressed.<br><br> This data is compressed with zlib and there is no header - default compression settings.                            |
| `unknown_24`     | Alignment, most likely.                                                                                                                                                                                             |

## Segment Header

```cpp
struct FFXIVARR_PACKET_SEGMENT_HEADER
{
  uint32_t size;
  uint32_t source_actor;
  uint32_t target_actor;
  uint16_t type;
  uint16_t padding;
};
```

| Field          | Description                                                                                                                                                                           |
| :---           | :---                                                                                                                                                                                  |
| `size`         | The size of this segment and its data (if any).                                                                                                                                       |
| `source_actor` | The actor ID of the actor who effectively caused this packet to be sent.<br><br>For example, if another player casts an action, the `source_actor` field will contain their actor ID. |
| `target_actor` | The actor ID of the actor who is affected by the packet.<br><br>This isn't used consistently, but the same logical rules apply as `source_actor`.                                     |
| `type`         | The type of segment, see [below for more detail](#segment-types).<br><br>Based on the value of this field indicates what kind of data you'd expect to find after the segment header.  |
| `paddding`     | Alignment.                                                                                                                                                                            |

### Segment Types

```cpp
enum FFXIVARR_SEGMENT_TYPE
{
  SEGMENTTYPE_SESSIONINIT = 1,
  SEGMENTTYPE_IPC = 3,
  SEGMENTTYPE_KEEPALIVE = 7,
  //SEGMENTTYPE_RESPONSE = 8,
  SEGMENTTYPE_ENCRYPTIONINIT = 9,
};
```

| Type                         | Description                                                                                                                                                                                                                                                                                                                                                                                                                              |
| :---                         | :---                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| `SEGMENTTYPE_SESSIONINIT`    | Used to login to a world or chat server.<br><br>The packet that has a segment that has a type set to this will contain a correct `connectionType` set in the [packet header](#packet-header). Use this to record what kind of connection it is.<br><br>Example implementation is in [Sapphire](https://github.com/SapphireServer/Sapphire/blob/399d9b0dcd6d87aa624bd53c58415efa27bb1b1c/src/world/Network/GameConnection.cpp#L430-L452). |
| `SEGMENTTYPE_IPC`            | Used for segments that contain data that should be handled by the packet router for the associated channel.<br><br>Chat messages, using actions and etc. will always be sent via this segment type and there will be a `FFXIVARR_IPC_HEADER` immediately following the segment header.                                                                                                                                                   |
| `SEGMENTTYPE_KEEPALIVE`      | TODO: can't remember where this is actually used - lobby?<br><br>As a note, world (and chat?) use IPCs to ping/pong. Because reasons.                                                                                                                                                                                                                                                                                                    |
| `SEGMENTTYPE_ENCRYPTIONINIT` | Used to initialize Blowfish for the [lobby channel](channels.md#lobby).<br><br>The client sends a packet to lobby with it's key phrase which is then used to """secure""" a lobby session (spoiler alert: it's not secure).                                                                                                                                                                                                              |

## IPC Header

Only present when the parent segment type is set to `SEGMENTTYPE_IPC`.

```cpp
struct FFXIVARR_IPC_HEADER
{
  uint16_t reserved;
  uint16_t type;
  uint16_t padding;
  uint16_t serverId;
  uint32_t timestamp;
  uint32_t padding1;
};
```

| Field       | Description                                                                                                                        |
| :---        | :---                                                                                                                               |
| `reserved`  |                                                                                                                                    |
| `type`      | This will contain the opcode of the packet which identifies which hanadler the packet data following this packet should go.        |
| `padding`   | Potentially data here and not padding but it's probably not that important. Right?                                                 |
| `serverId`  | TODO: write about retail server architecture.                                                                                      |
| `timestamp` | A Unix timestamp in seconds since the epoch.<br><br>Not really sure why this exists here but it does and that's what it has in it. |
| `padding1`  | Alignment.                                                                                                                         |

## Decoding Packets

Decoding packets is reasonably simple and assuming you have a buffer that you write data in to for each connection, it's something like the following:

```text
if buf.size < sizeof(FFXIVARR_PACKET_HEADER):
    return

header = &buf[0] as FFXIVARR_PACKET_HEADER:

if buf.size < header.size:
    return

data = slice buf from sizeof(FFXIVARR_PACKET_HEADER) to end of buf

if buf.isCompressed:
    data = zlib_inflate(data)

pos = 0
while true:
    segment = &data[pos] as FFXIVARR_PACKET_SEGMENT_HEADER

    if segment.size >= buf.size
        burn them

    if segment.size >= data.size:
        also burn them

    pos = segment.size

    seg_hdr_size = sizeof(FFXIVARR_PACKET_SEGMENT_HEADER)

    if segment.type == SEGMENTTYPE_IPC:
        ipc_size = segment.size - seg_hdr_size
        ipc_data = slice segment from seg_hdr_size to ipc_size

        ipc_hdr = &ipc_data[0] as FFXIVARR_IPC_HEADER
        ipc_hdr_size = sizeof(FFXIVARR_IPC_HEADER)

        packet_data = slice ipc_data from ipc_hdr_size to remaining size
        process_channel_packet(ipc_hdr.type, packet_data)

    // other segment types depend on the type of channel, but it's more of the same
```

A lot of detail is omitted for brevity, but it's generally pretty straightforward.

A more comprehensive example of packet parsing can be found in Sapphire:

* [Packet container](https://github.com/SapphireServer/Sapphire/blob/develop/src/common/Network/GamePacket.h) \(and some container-level parsing\)
* [Packet parsing](https://github.com/SapphireServer/Sapphire/blob/develop/src/common/Network/GamePacketParser.cpp)
