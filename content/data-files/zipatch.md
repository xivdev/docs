---
description: ZiPatch(.patch) is a file format used to update online games made by SQEX.
---

# ZiPatch

> We'll only cover version 3 for now.

## Intro

This patch format has been extant since FFXIV 1.0, but has had a few modifications since then, especially from 2.0 onward.

A patch file name generally starts with either H or D, for HIST and DIFF, respectively, followed by a version string, such as 2013.08.09.0001.0000. This is optionally followed by a lowercase letter \(starting at 'a'\) in case the patch file corresponding to that version string would be larger than 1.5GB for HIST files. e.g.: H2013.08.09.0001.0000a.patch, D2019.05.29.0000.0000.patch.

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

## Notes

* Byte order, unless explicitly mentioned, is big endian order. That is, `0x00AB_CDEF`  in hexadecimal will be encoded as `00 AB CD EF`  in file - not `EF CD AB 00` which is little endian.

## File Signature

All patch files start with

```text
91 5A 49 50 41 54 43 48 0D 0A 1A 0A
```

## Chunks

The ZiPatch signature is followed by a contiguous array of chunks with the following structure

```csharp
[StructLayout(LayoutKind.Explicit, Size = 8)]
struct ChunkHeader
{
    [FieldOffset(0)] UInt32BE Size;
    [FieldOffset(4)] char Name[4];
}
```

Where chunkSize indicates the size of the upcoming chunk content, and chunkType is a 4-character string indicating the type of the chunk, e.g., "FHDR", "APLY", and "SQPK".

Following ChunkHeader, there's a struct of size chunkSize describing the chunk contents, which will be detailed in the following pages. Following the chunk contents, there is a CRC32 of the chunkType with the chunk contents. 

This contiguous array terminates with a chunk of chunkType "EOF\_".

#### FHDR

todo: mention version, repo id, platform id, etc...

```csharp
[StructLayout(LayoutKind.Explicit, Size = 256)]
struct FhdrChunk
{
    [FieldOffset(3)] byte Version; // 
    [FieldOffset(4)] char Name[4];
}
```

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

