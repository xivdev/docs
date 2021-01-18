---
description: >-
  This page contains the file structure itself. What each of the structures
  listed here are used for can be on other pages.
---

# AVFX Files

AVFX files are organized as a nested series of blocks, with each block following the format:

```text
Name: 4 bytes
Size: 4 bytes
Contents: [Size] bytes
```

The contents of a block can further contain other blocks. It is also worth noting that the name of a block is reversed from its actual meaning. For example, the "top-level" block for an AVFX file is  "XFVA"\(AVFX reversed\). Names which are fewer than 4 character are also padded out to 4 bytes. Blocks are also padded out to be 4-aligned, so even if `Size`is 3, there will be an extra `00` before the next block starts.

## Overview

Note: the names of the blocks are reversed for readability. Also, the notation `TmLn[],` for example, simply means several sequential `TmLn` blocks, one directly after the other. There is no "list" structure in AVFX files.

The structure is also abridged for brevity, the full list of parameters can be found at the link below.

```text
AVFX:
    Ver: the AVFX version used?
    
    ...parameters....
    
    ScCn: number of schedulers in this file (always 1)
    TlCn: number of timelines
    EmCn: number of emitters
    PrCn: number of particles
    EfCn: number of effectors
    BdCn: number of binders
    TxCn: number of textures
    MdCn: number of models
    
    Schd: a scheduler block
    TmLn[]: a list of timeline blocks
    Emit[]: a list of emitter blocks
    Ptcl[]: a list of particle blocks
    Efct[]: a list of effector blocks
    Bind[]: a list of binder blocks
    Tex[]: a list of texture blocks
    Modl[]: a list of model blocks
```

\([Full structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Base/AVFXBase.cs)\)

## Scheduler \(`Schd`\)

```text
Schd:
    ItCn: item count
    TrCn: trigger count, always 12
    Item[]: a list of items
    Trgr[]: a list of triggers, always 12 Trgr blocks
```

#### Items and Triggers

The way `Item` and `Trgr` blocks are organized is somewhat unintuitive. Both of them have an identical structure:

```text
Item or Trgr:
    bEna: enabled
    StTm: start time
    TlNo: timeline index
```

However, each subsequent `Item/Trgr` will have the data of the previous appended to it. For example:

```text
Item:
    bEna
    StTm
    TlNo
    
Item:
    bEna : from item #0
    StTm : from item #0
    TlNo : from item #0
    bEna
    StTm
    TlNo
    
  Item:
    bEna : from item #0
    StTm : from item #0
    TlNo : from item #0
    bEna : from item #1
    StTm : from item #1
    TlNo : from item #1
    bEna
    StTm
    TlNo  
```

For this reason, the easiest way to read a list of `Item` is to take the last one, and split it into 3-block chunks.

## Timeline \(`TmLn`\)

```text
TmLn:
    ...parameters...
    
    TICn: number of items
    CpCn: number of clips
    
    Item[]: list of item blocks
    Clip[]: list of clip blocks
```

\([Full structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Timeline/AVFXTimeline.cs)\)

### Timeline Items

Timeline items have this [structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Timeline/AVFXTimelineSubItem.cs), and are similar to scheduler items in that each item contains the data of the previous ones as well.

### Timeline clips

Timeline clips are different in that the data they contain is not organized into blocks, but is rather one continuous 164-byte:

```text
4-byte string, reversed
4 4-byte ints
4 4-byte floats
4 32-byte strings
```

## Emitter \(`Emit`\)

```text
Emit:
    SdNm: the path to a sound file (.sdm)
    
    ...parameters....
    
    PrCn: number of particles
    EmCn: number of emitters

    ...animation curves...
    
    ItEm[]: list of emitter items
    ItPr[]: list of particles items
    
    Data: depends on the emitter type
```

\([Full structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Emitter/AVFXEmitter.cs)\)

The Data block contains information relevant to the emitter's type \(specified in the `EVT` parameter\). Depending on the type, the `Data` block may not exist at all \([structures](https://github.com/0ceal0t/Dalamud-VFXEditor/tree/main/AVFXLib/Models/Emitter/Data)\).

### Emitter/Particle Items

`ItEm` and `ItPr` blocks share the same basic [structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Emitter/AVFXEmitterIterationItem.cs), but follow the same pattern as items and triggers within schedulers, where previous items' data is appended to each subsequent one. However, in an emitter, all of the `ItEm` data is included in the `ItPr` data. As an example:

```text
ItEm:
    [ItEm data #0]
    
ItEm:
    [ItEm data #0]
    [ItEm data #1]
    
ItEm:
    [ItEm data #0]
    [ItEm data #1]
    [ItEm data #2]
    
ItPr:
    [ItEm data #0]
    [ItEm data #1]
    [ItEm data #2]
    [ItPr data #0]
    
ItPr:
    [ItEm data #0]
    [ItEm data #1]
    [ItEm data #2]
    [ItPr data #0]
    [ItPr data #1]
```

## Particle \(`Ptcl`\)

```text
Ptcl:

    ...parameters...
    
    UvSN: number of UV Sets
    
    ...more parameters...
    
    ...animation curves...
    
    Smpl: Simple animations (optional)
    
    UVSet[]: a list of UVSet blocks
    
    Data: depends on particle type
    
    TC1: texture color 1
    TC2: texture color 2 (optional)
    TC3: (optional)
    TC4: (optional)
    TN: texture normal
    TR: texture reflection
    TD: texture distortion
    TP: texture palette
```

\([Full structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXParticle.cs)\)

Like with emitters, the contents of the `Data` block depends on the particle type \(parameter `PrVT` \). Some particle types do not contain a `Data` block \([structures](https://github.com/0ceal0t/Dalamud-VFXEditor/tree/main/AVFXLib/Models/Particle/Data)\).

* [Simple animation structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXParticleSimple.cs)
* [UV Set structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXParticleUVSet.cs)
* [Texture color 1 structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXTextureColor1.cs)
* [Texture color 2, 3, and 4](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXTextureColor2.cs)
* [Texture normal](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXTextureNormal.cs)
* [Texture reflection](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXTextureReflection.cs)
* [Texture distortion](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXTextureDistortion.cs)
* [Texture palette](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXTexturePalette.cs)

### Particle Simple Animations

The `Smpl` block contains 2 unique parameters: `Cols` and `Frms`. `Cols` is 16 bytes, where each 4 bytes represent an rgba color \(each byte is one channel\). `Frms` is 8 bytes, where each 2 bytes is an integer.

## Effector \(`Efct`\)

```text
Efct:
    ...parameters...
    
    Data
```

\([Full structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Effector/AVFXEffector.cs)\)

As with emitters and particles, the `Data` block \([structures](https://github.com/0ceal0t/Dalamud-VFXEditor/tree/main/AVFXLib/Models/Effector/Data)\) depends on the type of effector, and may not exist.

## Binder \(`Bind`\)

```text
Bind:
    ...parameters...
    
    PrpS: Start binder properties
    Prp1: binder properties 1
    Prp2: binder properties 2
    PrpG: Goal binder properties
    
    Data
```

\([Full structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Binder/AVFXBinder.cs)\)

`Data` is, once again, dependent on the type of binder, and may not exist \([structures](https://github.com/0ceal0t/Dalamud-VFXEditor/tree/main/AVFXLib/Models/Binder/Data)\). Each of the binder properties have this [structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Binder/AVFXBinderProperty.cs).

## Texture \(`Tex`\)

Texture blocks are simply paths to `atex` files within the game's internal file structure.

## Model \(`Modl`\)

The embedded models have 4 possible blocks within them: `VNum` , `VDrw` , `VEmt`, and `VIdx` . All 4 of the blocks can be in the same model, however `VNum` and `VEmt` are always paired, as are `VIdx` and `VDrw` .

### `VIdx`

This is a list of 2-byte integers, where each 3 integers represents a triangle in the model. The integers themselves are the indexes of vertices within `VDrw` .

### `VDrw`

`VDrw` is a list of vertices, where each vertex is 36 bytes long with the following format:

```text
4 2-byte floats: position
4 1-byte ints: normal
4 1-byte ints: tangent
4 1-byte ints: color
4 2-byte floats: uv1
4 2-byte floats: uv2
```

### `VEmt`

This is a list of 28-byte vertices, with the following format:

```text
3 4-byte floats: position
3 4-byte floats: normal
4 1-byte ints: color
```

### `VNum`

This is a list of 2-byte integers, where each integer corresponds to a vertex in `VEmt` \(so the length of elements in `VNum` always equals the number in `VEmt`\).

## Curves

Curves have the following structure:

```text
[Curve Name]:
    ....parameters...
    
    Keys
```

\([Full structure](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Components/Curve/AVFXCurve.cs)\)

The name of a curve varies, but some examples are `X` ,`RGB` , `SclA` , etc. They are used to animate motion over time. `Keys` is a single block which contains the information on the shape of the curve. Every 16 bytes in `Keys` corresponds to a single keyframe, with the following format:

```text
2-byte integer: time
2-byte integer: type
4-byte float: X
4-byte float: Y
4-byte float: Z
```

