# SqexArg

## Encoded Process Argument

Upon launching the game, the retail launcher passes handful of information \(e.g. login token, client language, etc...\) to the game that usually looks like this:

```text
//**sqex0003VGhpcyBpcyBqdXN0IGZvciBleGFtcGxlIHB1cnBvc2U7IGl0IGFjdHVhbGx5IG5ldmVyIGxvb2sgbGlrZSB0aGlzA**//
```

### Encoding Process

* Encrypt UTF-8 plain text using Blowfish; you need to pad the buffer with zero as needed
  * Key is GetTickCount\(\) & 0xFFFF\_0000
  * Block cipher mode of operation is ECB \(yes, you read it right.\)
* Convert encrypted bytes to [Base64URL](https://base64.guru/standards/base64url)
* Format it as `//**sqex0003{base64}{checksum}**//`

### Checksum

#### Pseudocode

```csharp
char[] ChecksumTable = {
    'f', 'X', '1', 'p', 'G', 't', 'd', 'S',
    '5', 'C', 'A', 'P', '4', '_', 'V', 'L'
};

char GetChecksum(uint key) {
    // mask the nibble we're looking for
    var value = key & 0x000F_0000;

    return ChecksumTable[value >> 16];
}
```
