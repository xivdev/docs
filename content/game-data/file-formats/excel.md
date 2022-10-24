---
description: >-
  Excel is a binary data format for storing relational data. Contains info for
  EXL, EXH and EXD files.
---

# Excel

Excel is a binary data format for storing relational data. It's composed of 3 different files:

1. [Excel List \(.exl\)](excel.md#excel-list-exl) is used to provide the excel index for the game, and allows certain sheets to be accessed by an ID rather than a name.
2. [Excel Header \(.exh\)](excel.md#excel-header-exh) is used to define the data layout, variant, segmentation and available languages in the event of localisation being present.
3. [Excel Data \(.exd\)](excel.md#excel-data-exd) is the raw data itself and just contains an offset table and then data for each row. The structure of this file changes depending on which variant is defined in the header.

## Excel List \(.exl\)

Probably the simplest format in the entire game given it's just a text file.

The first line of the file is its 'header' and defines its type, `EXLT` and it's version following that. Each sequential line after the 'header' is a path, relative to the `exd/` category, and its immutable ID. The immutable ID is optional and in cases where not relevant \(eg. quest dialogue files\) it's value is `-1`.

For example, here's an example of the content of a list file:

```text
EXLT,2
Achievement,209
Action,4
content/DeepDungeon2Achievement,-1
content/DeepDungeon2Gacha,-1
```

From these entries, you can build something like the following:

| ID   | Relative Path/Sheet Name          | Header Path                               |
| :--- | :---                              | :---                                      |
| 209  | `Achievement`                     | `exd/achievement.exh`                     |
| 4    | `Action`                          | `exd/action.exh`                          |
|      | `content/DeepDungeon2Achievement` | `exd/content/deepdungeon2achievement.exh` |
|      | `content/DeepDungeon2Gacha`       | `exd/content/deepdungeon2gacha.exh`       |

From here, the only thing you can do is parse headers as you will not be able to accurately figure out data paths without first reading the header due to language and row segmentation.

As a note, any excel entry in this file with an ID set get their header pre-cached by the game on startup.

## Excel Header \(.exh\)

The Excel Header defines the schema and how you read data files. The first structure in this file is it's header which contains information you'll need to parse the rest of the file.

{% hint style="warning" %}
This file in its entirely is in [big endian](https://en.wikipedia.org/wiki/Endianness#Big-endian). You will need to convert this file to little endian on applicable systems.

For example, in C\#, `BitConverter.IsLittleEndian` will return whether or not a conversion needs to take place. See the [Lumina source code](https://github.com/NotAdam/Lumina/blob/master/Lumina/Data/Files/Excel/ExcelHeaderFile.cs) for this file for a working example.
{% endhint %}

{% tabs %}
{% tab title="C++" %}

```cpp
struct ExhHeader
{
  char magic[0x4];
  uint16_t unknown;
  uint16_t dataOffset;
  uint16_t columnCount;
  uint16_t pageCount;
  uint16_t languageCount;
  uint16_t unknown1;
  uint8_t u2;
  uint8_t variant;
  uint16_t u3;
  uint32_t rowCount;
  uint32_t u4[2];
};
```

{% endtab %}

{% tab title="C\#" %}

```csharp
[StructLayout( LayoutKind.Sequential )]
public unsafe struct ExcelHeaderHeader
{
    public fixed byte Magic[4];
    // todo: not sure? maybe?
    public ushort Version;
    public ushort DataOffset;
    public ushort ColumnCount;
    public ushort PageCount;
    public ushort LanguageCount;
    private ushort _unknown1;
    private byte _unknown2;
    public ExcelVariant Variant;
    private ushort _unknown3;
    public uint RowCount;
    private fixed uint U4[2];
}
```

{% endtab %}
{% endtabs %}

### Magic

The magic is always `EXHF`. If it's not, the file is probably not the file you're trying to read.

### Data Offset

`DataOffset` isn't relevant to this file at all, but is required when loading certain data from Excel Data files such as strings. It points to the end of the fixed size data of a row. For example, a row can be made of a bunch of integral types which have a known length at compile time, however a string length is variable. This offset allows you to then seek to the end of the row and access any additional data that may be on the end. If this is weird, don't worry, because it'll make sense later.

### Column Count

`ColumnCount` is how many columns exist within the file and is the first thing you'll read after the header. In other words, you'll need to read `sizeof( ColumnDefinition ) * ColumnCount` immediately after the header.

```cpp
enum ExcelColumnDataType : uint16_t
{
    String = 0x0,
    Bool = 0x1,
    Int8 = 0x2,
    UInt8 = 0x3,
    Int16 = 0x4,
    UInt16 = 0x5,
    Int32 = 0x6,
    UInt32 = 0x7,
    Float32 = 0x9,
    Int64 = 0xA,
    UInt64 = 0xB,

    // 0 is read like data & 1, 1 is like data & 2, 2 = data & 4, etc...
    PackedBool0 = 0x19,
    PackedBool1 = 0x1A,
    PackedBool2 = 0x1B,
    PackedBool3 = 0x1C,
    PackedBool4 = 0x1D,
    PackedBool5 = 0x1E,
    PackedBool6 = 0x1F,
    PackedBool7 = 0x20,
};
```

{% tabs %}
{% tab title="C++" %}

```cpp
struct ExcelColumnDefinition
{
    ExcelColumnDataType type;
    uint16_t offset;
};
```

{% endtab %}

{% tab title="C\#" %}

```csharp
[StructLayout( LayoutKind.Sequential )]
public struct ExcelColumnDefinition
{
    public ExcelColumnDataType Type;
    public ushort Offset;
}
```

{% endtab %}
{% endtabs %}

`Offset` is relative to the row offset, which you don't have until you read the offset table from a data file.

`Type` is the type of data stored. Most don't have any special handling outside of `String` and `PackedBoolX` but we'll cover that later.

### Page Count

`PageCount` is the number of 'pages' an excel data sheet is split into. Many sheets only have a single page and every row will exist in a single page, however larger sheets such as `Quest` or `Item` have many pages. This information is another structure and immediately follows the column definition data.

{% tabs %}
{% tab title="C++" %}

```cpp
struct ExcelDataPagination
{
    uint32_t startId;
    uint32_t rowCount;
}
```

{% endtab %}

{% tab title="C\#" %}

```csharp
[StructLayout( LayoutKind.Sequential )]
public struct ExcelDataPagination
{
    public uint StartId;
    public uint RowCount;
}
```

{% endtab %}
{% endtabs %}

`startId` is the row id where a page starts. You'll need this to build file paths for data files.

`rowCount` is how many parent rows a sheet contains. As a quick example before we cover it more in depth later is that given a row id, you can calculate which page a row is on with `row >= startId && row < startId + rowCount - 1`.

### Language Count

Finally, the last thing you'll need to read out of a header file is the languages. These are needed to generate paths to data files along with the paging information.

```cpp
enum Language : uint16_t
{
    None,
    // ja
    Japanese,
    // en
    English,
    // de
    German,
    // fr
    French,
    // chs
    ChineseSimplified,
    // cht
    ChineseTraditional,
    // ko
    Korean
}
```

You can read out the languages as is.

### Variant

```cpp
enum ExcelVariant : uint8_t
{
    Unknown,
    Default,
    SubRows
}
```

Used when reading data. `Default` requires no extra processing and you can just iterate over the offset list inside a data file. `SubRows` makes each row contain it's own rows. As a better example, it's like having a compound key on a database table. Instead of one column being the identifier for a row, you have two instead.

### Row Count

This is the total count of all rows across every page. The game uses this field when it internally queries for a row count.

## Generating Data File Paths

Once you have the 3 pieces of critical information from the headers, namely:

1. The column count
2. The page count
3. The languages

You have everything you need to find data files! How exciting. The files follow one of 2 path formats, which makes this pretty easy. Make sure not to discard the data from the header, there's still some other information you'll need from it.

If the no language is set, your paths follow the following format:

```text
exd/<name>_<page.startId>.exd
```

Otherwise, if one or many languages are set \(as in, not `None`\), the following format applies:

```text
exd/<name>_<page.startId>_<languageCode>.exd
```

This should be relatively obvious, but here's a few examples:

| Name  | Page Start ID | Language        | Path                     |
| :---  | :---          | :---            | :---                     |
| Item  | 0             | English \(en\)  | `exd/item_0_en.exd`      |
| Item  | 10000         | Japanese \(ja\) | `exd/item_10000_ja.exd`  |
| Mount | 0             | French \(fr\)   | `exd/mount_0_fr.exd`     |
| Quest | 65536         | German \(de\)   | `exd/quest_65536_de.exd` |

The above also applies for quest sheets and so on which exist in subfolders.

## Excel Data \(.exd\)

The data file contains a single page of sheet data and as mentioned before, you will need the header file to read data correctly.

{% hint style="warning" %}
Similarly to [Excel Headers](excel.md#excel-header-exh), excel data files are entirely in [big endian](https://en.wikipedia.org/wiki/Endianness#Big-endian) and will need to be converted to little endian on applicable systems.
{% endhint %}

{% tabs %}
{% tab title="C++" %}

```cpp
struct ExcelDataHeader
{
  char magic[0x4];
  uint16_t version;
  uint16_t unknown1;
  uint32_t indexSize;
  uint32_t unknown2[5];
};
```

{% endtab %}

{% tab title="C\#" %}

```csharp
[StructLayout( LayoutKind.Sequential )]
public unsafe struct ExcelDataHeader
{
    public fixed byte Magic[4];
    public UInt16 Version;
    private UInt16 U1;
    public UInt32 IndexSize;
    private fixed UInt16 U2[10];
}
```

{% endtab %}
{% endtabs %}

The value of `magic` should always be `EXDF`.

`indexSize` is how large the row offset index is, in terms of total size. To convert that to a number of entries, you'd do `indexSize / sizeof( ExcelDataOffset )`.

### Data Offset Entries

Immediately following the `ExcelDataHeader`, the root row offsets are stored. The reason it's called the 'root row offset' is because on variant 2 sheets \(or sheets with subrows\), this offset won't point to data that can be read following the column data.

{% tabs %}
{% tab title="C++" %}

```cpp
struct ExcelDataOffset
{
    uint32_t rowId;
    uint32_t offset;
};
```

{% endtab %}

{% tab title="C\#" %}

```csharp
[StructLayout( LayoutKind.Sequential )]
public struct ExcelDataOffset
{
    public UInt32 RowId;
    public UInt32 Offset;
}
```

{% endtab %}
{% endtabs %}

`rowId` is the absolute row id, so a simple way to map these in whatever you're doing is to convert the list of data offsets in this file to a key value map, where the key is the `rowId` and the value is the `offset`. Then you can directly index `rowId`s on any given data page.

`offset` is the absolute offset to where the data is located in the file. It can be used as is.

### Row Header

Once you seek to a row offset by following the offset list after the header, the first thing you'll encounter is the row header.

{% tabs %}
{% tab title="C++" %}

```cpp
struct ExcelDataRowHeader
{
    uint32_t dataSize;
    uint16_t rowCount;
};
```

{% endtab %}

{% tab title="C\#" %}

```csharp
[StructLayout(LayoutKind.Sequential)]
public struct ExcelDataRowHeader
{
    public uint DataSize;
    public ushort RowCount;
}
```

{% endtab %}
{% endtabs %}

The `dataSize` is the entire size of the row, including any data for subrows \(if they exist\). You can use this field to copy out the exact amount of data for a row \(or subrows\) to then later parse if you choose not to do it in place.

`rowCount` is always 1 on variant 1 sheets and you can ignore that field entirely if you choose to. However, on variant 2 sheets, the `rowCount` is how many subrows belong to a row.

Therefore, on variant 1 sheets, immediately after the row header is your row data. You can then read columns directly out of the data given a column offset that you read from the header.

On the other hand, variant 2 sheets, following the header is the first subrow, or subrow 0. You can calculate the offset to n subrow with the following:

```text
rowOffset + 6 + ( subRowId * header.dataOffset + 2 * ( subRowId + 1 ) );
```

To clear up a few things:

1. The `rowOffset` is the offset from the offset list.
2. `rowOffset + 6` is the skipping the size of the row header. You could just store the offset once you read the row header and use that.
3. `header.dataOffset` points to the end of the raw data of the row, or is basically the 'fixed' size of a row, not including strings. This lets you seek to the end of a row and immediately go to the next subrow.

There are some intricacies to reading certain types of columns which we'll cover in the next section.

### Reading Row Data

Reading data out of a row depends a bit on the type of the column that you're reading. Most don't require any additional logic and you can read them out of the row and use them as is.

All of the types are as follows:

```cpp
enum ExcelColumnDataType : uint16_t
{
    String = 0x0,
    Bool = 0x1,
    Int8 = 0x2,
    UInt8 = 0x3,
    Int16 = 0x4,
    UInt16 = 0x5,
    Int32 = 0x6,
    UInt32 = 0x7,
    Float32 = 0x9,
    Int64 = 0xA,
    UInt64 = 0xB,

    // 0 is read like data & 1, 1 is like data & 2, 2 = data & 4, etc...
    PackedBool0 = 0x19,
    PackedBool1 = 0x1A,
    PackedBool2 = 0x1B,
    PackedBool3 = 0x1C,
    PackedBool4 = 0x1D,
    PackedBool5 = 0x1E,
    PackedBool6 = 0x1F,
    PackedBool7 = 0x20,
};
```

#### String

As mentioned previously, variable length data is stored past the end of the fixed length data segment of a row. So to access a string, you need to read a `uint32` where there string column is. You can then obtain the offset of the string by doing the following:

```text
rowOffset + header.dataOffset + columnValue
```

Where `rowOffset` is the offset of the first column of a row, the `dataOffset` from the header and the `uint32` that you read out from the column.

#### Packed Bools

Packed bools are always 8 bits/1 byte long. To each type is basically which bit you need to bitwise and against to read the correct bool out.

A simple way of doing this for all of them is something like the following:

```text
var shift = (int)column.type - (int)ExcelColumnDataType.PackedBool0;
var bit = 1 << shift;

return (data & bit) == bit;
```

Alternatively, you can handle each one indivdually, but it's better to be lazy and do it the lazy way instead.

#### Everything Else

Read and use it as is. It just works™ - no magic required. Just make sure the endianness is correct.
