# SQPK

## Primitives

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

Important to note that any fields prepended with "Block" will mean that the number is in blocks, or units of 128-bytes. e.g., BlockOffset means that the offset in bytes would be calculated by BlockOffset << 7 or BlockOffset \* 128.

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

```csharp
struct BlockCount {
	[FieldOffset(0x00)] UInt32BE Value;

	UInt32 InBytes => Value * 128;
}
```

```csharp
struct SqpkFilePath {
	[FieldOffset(0x00)] UInt16BE Main;
	[FieldOffset(0x02)] UInt32BE Sub;
	[FieldOffset(0x04)] UInt32BE File;	
}
```

```csharp
struct SqpkFileRange {
	[FieldOffset(0x00)] BlockCount Offset;
	[FieldOffset(0x04)] BlockCount Count;
}
```

## Types

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

This operation writes SqpkAddData.Data to the dat File, at BlockOffset. It will then write BlockDeleteCount blocks of empty (0x00) 128-bytes.

### Type D - Delete Data

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

This operation writes BlockCount empty (0x00) 128-byte blocks at BlockOffset, with the first of those blocks containing a BlockHeader struct with:`Size = 128, Type = FileSize = UsedBlocks = 0, TotalBlocks = BlockCount`

If Delete Data encounters EOF while writing or seeking to BlockOffset, it will fail.

### Type E - Expand Data

Expand Data follows the same structure as Delete Data, but the behaviour differs. When Expand Data seeks past the end of file or writes past the end of file, it does not fail, since this is its intended use.

### Type F - File Operation

#### Pseudocode

```csharp
Uint64 AlignBlockSize(UInt64 size) {
	return (size + 0x8F) & 0xFFFFFF80;
}

[StructLayout(Size = 0x1B)]
struct FileHeader
{
	[FieldOffset(0x00)] byte Operation;
	// padding: [u8; 2]
	[FieldOffset(0x03)] UInt64BE Offset;
	[FieldOffset(0x0B)] UInt64BE Size;
	[FieldOffset(0x13)] UInt32BE FilePathSize;
	[FieldOffset(0x17)] UInt16BE ExpansionId;
	// padding: [u8; 2]
}

[StructLayout(Size = 0x10)]
struct FileBlockHeader
{
	[FieldOffset(0x00)] UInt32LE Size;
	// padding: [u8; 4]
	[FieldOffset(0x08)] UInt32LE CompressedSize;
	[FieldOffset(0x0C)] UInt32LE DecompressedSize;

	bool IsBlockCompressed => CompressedSize != 32000;
	
	long BlockSize => IsBlockCompressed switch {
		true => CompressedSize,
		false => DecompressedSize,
	};
	
	long AlignedBlockSize => AlignBlockSize(BlockSize);
}
```

```
FileChunk:
+------------+==========+~~~~~~~~~~~~~~~~+
| FileHeader | FilePath | SqpkFileBlocks |
+------------+==========+~~~~~~~~~~~~~~~~+

Notes:
- FilePath is a null terminated utf-8 string. Length of the string is designated by FileHeader.FilePathSize
```

```
SqpkFileBlocks:
+-------------+==============+=======+-------------+==============+
| BlkHeader#0 | BlkPayload#0 | pad#0 | BlkHeader#1 | BlkPayload#1 |
+-------------+==============+=======+-------------+==============+
 <------- BlockSize#0 ------->        <---- BlockSize#1 ---------->
 <------- AlignedBlockSize#0 -------> <---- AlignedBlockSize#1 ----
+=======+~~~~~+-------------+==============+=======+
| pad#1 | ... | BlkHeader#N | BlkPayload#N | pad#N |
+=======+~~~~~+-------------+==============+=======+
			   <------- BlockSize#N ------>
 ------>       <-------- AlignedBlockSize#N ------->

Notes:
- If blkHeader.Compressed is true then the payload is a deflated stream.
- If blkHeader.Compressed is false then the payload is a raw bytes stream.
- Yes, AlignedBlockSize is very dodgy. Apparently they are rounded up to next multiple of 128 except they're not.
- There are no good ways to determine how many blocks are actually encoded in SqpkFileBlocks.
	- Usually the last block won't be compressed but keeping track of payload.remaining() and stop if it's all read will be more robust against a forged file.
```

```csharp
void ApplyChunk(FileHeader header)
{
	var filePath = ReadCString(header.FilePathSize);
	var file = OpenFile(filePath);
	
	file.SeekTo(header.Offset);

	// assuming:
	// chunkCurrent = beginning of blkHeader#0
	// chunkEnd     = end of pad#N
	var (chunkCurrent, chunkEnd) = GetChunkPosition();
	while chunkCurrent < chunkEnd {
		patchFile.SeekTo(chunkCurrent);

		var blockHeader = ReadBlockHeader();
		var payload = ReadBlockPayload(header.BlockSize);
		
		var stream = blockHeader.IsCompressed switch {
			true => new DeflateStream(payload, CompressionMode.Decompress);
			false => payload,
		};

		stream.CopyTo(file);

		chunkCurrent += blockHeader.AlignedBlockSize;
	}
}
```

### Type H - Header Update

```csharp
enum FileKind : byte
{
	Dat = b'D',   // id.platform.datN
	Index = b'I', // id.platform.indexN
}

enum HeaderKind : byte
{
	Version = b'V',
	Data = b'D',
	Index = b'I',
}

struct HeaderChunkHeader
{
	[FieldOffset(0x00)] FileKind FileKind;
	[FieldOffset(0x01)] HeaderKind HeaderKind;
	[FieldOffset(0x03)] SqpkFilePath Path;
}
```

```
+-------------------+---------------------+
| HeaderChunkHeader | Payload: [u8; 1024] |
+-------------------+---------------------+
```

#### Pseudocode

```csharp
void ApplyChunk(HeaderChunkHeader header, byte payload[1024])
{
	var path = ResolvePath(header.Path, header.FileKind);
	var file = OpenFile(path);

	var writeOffset = header.HeaderKind switch {
		HeaderKind.Version => 0,
		HeaderKind.Data => 1024,
		HeaderKind.Index => 1024,
	};

	file.Write(writeOffset, payload);
}
```

### Type I - Index Update

This is currently no-op.

### Type X - Patch Info

This is currently no-op.

### Type T - Target Info

```csharp
struct TargetHeader
{
	// ..platform: ps3, ps4, win32...
}
```
