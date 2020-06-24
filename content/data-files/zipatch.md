---
description: ZiPatch(.patch) is a file format used to update online games made by SQEX.
---

# ZiPatch

> We'll only cover version 3 for now.

## Patch Naming Convention

Patch files follow the following naming convention:

```text
<D|H><YEAR>.<MONTH>.<DAY>.<PART>.<REVISION>.patch
```

Where `D|H` indicates that a patch is a delta patch or a history patch respectively.

Some example patch names are as follows:

```text
H2017.06.06.0000.0001a.patch
H2017.06.06.0000.0001b.patch
D2017.07.11.0000.0001.patch
D2019.04.16.0000.0000.patch
```

## File Structure

* Byte order, unless explicitly mentioned, is big endian order. That is, `0x00AB_CDEF`  in hexadecimal will be encoded as `00 AB CD EF`  in file - not `EF CD AB 00` which is little endian.

TODO: magic signature

```text
91 5A 49 50 41 54 43 48 0D 0A 1A 0A
```

## Chunks

TODO

```csharp
[StructLayout(LayoutKind.Explicit, Size = 8)]
struct ChunkHeader
{
    [FieldOffset(0)] UInt32BE Size;
    [FieldOffset(4)] char Name[4];
}
```

todo: payload, crc32

### FHDR

todo: mention version, repo id, platform id, etc...

### APLY

### SQPK

todo: path resolving, alignment, little endian...

#### Type A

#### Type D

#### Type E

todo: expand \(expansion only\)

#### Type F

todo: file block which is shared with .sqpk

#### Type H

#### Type I

#### Type T

#### Type X

unused?

### \_EOF

Indicates no chunks should be processed after this.

```csharp
[StructLayout(LayoutKind.Explicit, Size = 32)]
struct EofChunk
{
    // zero padded
}
```

## Links

[ZiPatch File Structure](http://ffxivclassic.fragmenterworks.com/wiki/index.php/ZiPatch_File_Structure)

