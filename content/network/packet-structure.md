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

<table>
  <thead>
    <tr>
      <th style="text-align:left">Field</th>
      <th style="text-align:left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left"><code>magic</code>
      </td>
      <td style="text-align:left">
        <p>A magic value that identifies a packet.</p>
        <p></p>
        <p>This is <code>FF14ARR</code> if you read it both in it&apos;s hexadecimal
          and ascii representation at the same time.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>timestamp</code>
      </td>
      <td style="text-align:left">The number of milliseconds since the unix epoch when the packet was sent</td>
    </tr>
    <tr>
      <td style="text-align:left"><code>size</code>
      </td>
      <td style="text-align:left">The size of the entire packet including its segments and data</td>
    </tr>
    <tr>
      <td style="text-align:left"><code>connectionType</code>
      </td>
      <td style="text-align:left">
        <p>The connection type. This will be 1 for zone channel connections and 2
          for chat.</p>
        <p></p>
        <p>This is only sent on the initial connection now, previously this was sent
          with every packet but that is no longer the case.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>unknown_20</code>
      </td>
      <td style="text-align:left">Alignment most likely</td>
    </tr>
    <tr>
      <td style="text-align:left"><code>isCompressed</code>
      </td>
      <td style="text-align:left">
        <p>Whether the segments + remaining data is compressed. The header is always
          uncompressed</p>
        <p></p>
        <p>This data is compressed with zlib and there is no header - default compression
          settings.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>unknown_24</code>
      </td>
      <td style="text-align:left">Alignment</td>
    </tr>
  </tbody>
</table>

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

<table>
  <thead>
    <tr>
      <th style="text-align:left">Field</th>
      <th style="text-align:left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left"><code>size</code>
      </td>
      <td style="text-align:left">The size of this segment and its data (if any)</td>
    </tr>
    <tr>
      <td style="text-align:left"><code>source_actor</code>
      </td>
      <td style="text-align:left">
        <p>The actor id of the actor who effectively caused this packet to be sent.</p>
        <p></p>
        <p>For example, if another player casts an action, the <code>source_actor</code> field
          will contain their actor id</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>target_actor</code>
      </td>
      <td style="text-align:left">
        <p>The actor id of the actor who is affected by the packet</p>
        <p></p>
        <p>This isn&apos;t used consistently, but the same <em>logical</em> rules apply
          as <code>source_actor</code>.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>type</code>
      </td>
      <td style="text-align:left">
        <p>The type of segment, see <a href="packet-structure.md#segment-types">below for more detail</a>.</p>
        <p></p>
        <p>Based on the value of this field indicates what kind of data you&apos;d
          expect to find after the segment header.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>padding</code>
      </td>
      <td style="text-align:left">Alignment</td>
    </tr>
  </tbody>
</table>

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

<table>
  <thead>
    <tr>
      <th style="text-align:left">Type</th>
      <th style="text-align:left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left"><code>SEGMENTTYPE_SESSIONINIT</code>
      </td>
      <td style="text-align:left">
        <p>Used to login to a world or chat server.</p>
        <p></p>
        <p>The packet that has a segment that has a type set to this will contain
          a correct <code>connectionType</code> set in the <a href="packet-structure.md#packet-header">packet header</a>.
          Use this to record what kind of connection it is.</p>
        <p></p>
        <p>Example implementation is in <a href="https://github.com/SapphireServer/Sapphire/blob/399d9b0dcd6d87aa624bd53c58415efa27bb1b1c/src/world/Network/GameConnection.cpp#L430-L452">Sapphire</a>.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>SEGMENTTYPE_IPC</code>
      </td>
      <td style="text-align:left">
        <p>Used for segments that contain data that should be handled by the packet
          router for the associated channel.</p>
        <p></p>
        <p>Chat messages, using actions and etc. will always be sent via this segment
          type and there will be a <code>FFXIVARR_IPC_HEADER</code> immediately following
          the segment header.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>SEGMENTTYPE_KEEPALIVE</code>
      </td>
      <td style="text-align:left">
        <p>to-do: can&apos;t remember where this is actually used - lobby?</p>
        <p></p>
        <p>As a note, world (and chat?) use IPCs to ping/pong. Because reasons.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>SEGMENTTYPE_ENCRYPTIONINIT</code>
      </td>
      <td style="text-align:left">
        <p>Used to initialise blowfish for the <a href="channels.md#lobby">lobby channel</a>.</p>
        <p></p>
        <p>The client sends a packet to lobby with it&apos;s key phrase which is
          then used to &apos;&apos;&apos;&apos;&apos;&apos;secure&apos;&apos;&apos;&apos;&apos;&apos;
          a lobby session.</p>
        <p></p>
        <p>Spoiler alert: it&apos;s not secure</p>
      </td>
    </tr>
  </tbody>
</table>

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

<table>
  <thead>
    <tr>
      <th style="text-align:left">Field</th>
      <th style="text-align:left">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="text-align:left"><code>reserved</code>
      </td>
      <td style="text-align:left"></td>
    </tr>
    <tr>
      <td style="text-align:left"><code>type</code>
      </td>
      <td style="text-align:left">This will contain the opcode of the packet which identifies which handler
        the packet data following this packet should go.</td>
    </tr>
    <tr>
      <td style="text-align:left"><code>padding</code>
      </td>
      <td style="text-align:left">potentially data here and not padding but it&apos;s probably not important
        &#x1F643;</td>
    </tr>
    <tr>
      <td style="text-align:left"><code>serverId</code>
      </td>
      <td style="text-align:left">to-do: write about retail server architecture</td>
    </tr>
    <tr>
      <td style="text-align:left"><code>timestamp</code>
      </td>
      <td style="text-align:left">
        <p>A Unix timestamp in seconds since the epoch.</p>
        <p></p>
        <p>Not really sure why this exists here but it does and that&apos;s what
          it has in it.</p>
      </td>
    </tr>
    <tr>
      <td style="text-align:left"><code>padding1</code>
      </td>
      <td style="text-align:left">Alignment</td>
    </tr>
  </tbody>
</table>

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

