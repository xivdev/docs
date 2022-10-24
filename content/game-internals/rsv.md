---
description: >-
  RSV is a placeholder value used for masking the actual value until the player
  is actually zoned in.
---

# RSV

The packet sent from the server upon entering the instance is as follows:

```csharp
// sent for each rsv string
struct RsvPkt {
  UInt32 value_size;    // len(without_nul_char(value))
  char key_str[32];     // null terminated
  char value_str[1024]; // null terminated
}
```

## Pseudocode

```csharp
void OnRsvPktreceived(RsvPkt pkt) {
  // e.g.) "_rsv_29752_-1_1_C0_0Action"
  var key = ReadCString(pkt.key_str);
  // e.g.) "Alternative End"
  var val = ReadCString(pkt.value_str);

  rsvMap[key] = val;
}

string GetActionName(int row) {
  var val = table[row, col];

  if (rsvMap.Contains(val)) {
    var key = val;
    return rsvMap[key];
  } else {
    return val;
  }
}
```

## Links

* <https://github.com/NotAdam/Lumina/blob/0530a97d21/src/Lumina/Excel/RSV/RsvProvider.cs>
