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
struct ChunkEntry
{
    ChunkHeader Header;
    Chunk Payload; // TODO: explain this
    UInt32BE Crc32;
}
```

```csharp
[StructLayout(LayoutKind.Explicit, Size = 8)]
struct ChunkHeader
{
    [FieldOffset(0)] UInt32BE Size;
    [FieldOffset(4)] char Name[4];
}
```

Where Header.Size indicates the size of Chunk.Payload, and Header.Name is a 4-character string indicating the type of the chunk, e.g., "FHDR", "APLY", and "SQPK".

Following Header, there's a Chunk describing the chunk contents, which will be detailed in the following pages. Following the chunk payload, there is a CRC32 of Header.Name with Payload. 

This contiguous array of chunks terminates with a chunk of Name "EOF\_".

### FHDR - File Header

```csharp
[StructLayout(LayoutKind.Explicit, Size = 256)]
struct FhdrChunk
{
    [FieldOffset(0x2)] byte Version; // ZIPATCH version (3)
    [FieldOffset(0x4)] char Name[4];
    // TODO...
    [FieldOffset(0x20)] UInt32BE DepotHash; // also observable in url
}
```

FHDR is always the first chunk in the file, containing a few unused fields and some information about the current patch file \(such as number of commands, etc.\)

FhdrChunk.Name has been observed to be HIST for history patches, or DIFF for delta patches.

### APLY - Apply Option

```csharp
[StructLayout(LayoutKind.Explicit, Size = 12)]
struct AplyChunk
{
    // 1 -> Ignore Missing; 2 -> Ignore Mismatch
    [FieldOffset(0x0)] UInt32BE Option;
    // Believed to be length (in bytes) of Value, but it doesn't currently change
    [FieldOffset(0x4)] UInt32BE Reserved;
    // Non-zero Value sets Option to true for this .patch file
    [FieldOffset(0x8)] UInt32BE Value; 
}
```

The two currently known Options, Ignore Missing and Ignore Mismatch are normally set to false via two APLY chunks set right after the FHDR. This means that the official patcher fails if a file it expects there is missing or some data it expects to be there is not.

### ADIR - Add Directory

```csharp
[StructLayout(LayoutKind.Explicit)]
struct AdirChunk
{
    [FieldOffset(0x0)] UInt32BE PathLength;
    [FieldOffset(0x4)] char Path[PathLength]; // TODO: This isn't valid C#
}
```

Creates directory at Path. Path is relative to the game folder plus the patch type being applied \(boot or game\). 

e.g.: If Path = "movie\ex1", and we are patching 'game' at "C:\Games\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\", we would create the folder "ex1" at location "C:\Games\SquareEnix\FINAL FANTASY XIV - A Realm Reborn\game\movie\"

### DELD - Delete Directory

```csharp
[StructLayout(LayoutKind.Explicit)]
struct DeldChunk
{
    [FieldOffset(0x0)] UInt32BE PathLength;
    [FieldOffset(0x4)] char Path[PathLength]; // TODO: This isn't valid C#
}
```

Similar to ADIR, but the folder at Path is deleted instead. It only deletes empty folders.

### SQPK

todo: path resolving, alignment, little endian...

```csharp
[StructLayout(LayoutKind.Explicit, Size = 5)]
struct SqpkChunk
{
    [FieldOffset(0x0)] Uint32BE Size;
    [FieldOffset(0x4)] SqpkOperation Opcode;
    [FieldOffset(0x5)] SqpkPayload Payload;
}

enum SqpkOperation : byte
{
    A, // Add data. Used to overwrite blocks in dat files. Can also delete old data
    D, // Delete data. Used to delete blocks (overwrite with 0x00) in dat files
    E, // Expand data. Used to insert empty blocks into dat files
    F, // File operations. Adding files, deleting files, etc.
    H, // Header Update. Updates headers of dat or index files
    I, // Index Add/Delete. Present in patch files but unused
    X, // Patch Info. Present in patch files but unused
    T, // Target Info. Present in patch files but only one field is used
}
```

SqpkChunk is a 'container' chunk which executes one of several operations in SqpkOperation. These will be detailed in the following subsections.

Important to note that any fields prepended with "Block" will mean that the number is in blocks, or units of 128-bytes. e.g., BlockOffset means that the offset in bytes would be calculated by BlockOffset &lt;&lt; 7 or BlockOffset \* 128.

These operations often contain fields indicating which file the operation will apply to. These adhere to the following structure:

```csharp
[StructLayout(LayoutKind.Explicit, Size = 8)]
struct SqpkFile
{
    [FieldOffset(0x0)] UInt16BE MainId;
    [FieldOffset(0x2)] UInt16BE SubId;
    [FieldOffset(0x4)] UInt32BE FileId;
    
    // Expansion => (byte)(SubId >> 8);
    // DatFileName => $"{MainId:x2}{SubId:x4}.win32.dat{FileId}"
    // IndexFileName => $"{MainId:x2}{SubId:x4}.win32.index{(FileId == 0 ? string.Empty : FileId.ToString())}"
}
```

When referring to block headers, the following struct will be relevant:

```csharp
[StructLayout(LayoutKind.Explicit, Size = 128)]
struct BlockHeader
{
    [FieldOffset(0x0)] UInt32LE Size;
    [FieldOffset(0x4)] UInt32LE Type;
    [FieldOffset(0x8)] UInt32LE FileSize;
    [FieldOffset(0xC)] UInt32LE TotalBlocks;
    [FieldOffset(0x10)] UInt32LE UsedBlocks;
}
```

#### Type A - Add Data

```csharp
[StructLayout(LayoutKind.Explicit)]
struct SqpkAddData
{
    [FieldOffset(0x0)] byte reserved[3];
    [FieldOffset(0x3)] SqpkFile File; // Dat file
    [FieldOffset(0xB)] UInt32BE BlockOffset;
    [FieldOffset(0xF)] UInt32BE BlockCount;
    [FieldOffset(0x13)] UInt32BE BlockDeleteCount;
    [FieldOffset(0x17)] byte Data[BlockCount << 7]; // TODO: Not valid C#
}
```

This operation writes SqpkAddData.Data to the dat File, at BlockOffset. It will then write BlockDeleteCount blocks of empty \(0x00\) 128-bytes.

#### Type D - Delete Data

```csharp
[StructLayout(LayoutKind.Explicit, Size = 19)]
struct SqpkDeleteData
{
    [FieldOffset(0x0)] byte reserved[3];
    [FieldOffset(0x3)] SqpkFile File; // Dat file
    [FieldOffset(0xB)] UInt32BE BlockOffset;
    [FieldOffset(0xF)] UInt32BE BlockCount;
}
```

This operation writes BlockCount empty \(0x00\) 128-byte blocks at BlockOffset, with the first of those blocks containing a BlockHeader struct with:`Size = 128, Type = FileSize = UsedBlocks = 0, TotalBlocks = BlockCount`

If Delete Data encounters EOF while writing or seeking to BlockOffset, it will fail.

#### Type E - Expand Data

Expand Data follows the same structure as Delete Data, but the behaviour differs. When Expand Data seeks past the end of file or writes past the end of file, it does not fail, since this is its intended use.

#### Type F - File Operation

todo: file block which is shared with .sqpk

#### Type H - Header Update

#### Type I - Index Update

#### Type X - Patch Info

#### Type T - Target Info

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

[https://github.com/goatcorp/FFXIVQuickLauncher/tree/master/XIVLauncher.PatchInstaller/ZiPatch](https://github.com/goatcorp/FFXIVQuickLauncher/tree/master/XIVLauncher.PatchInstaller/ZiPatch)

