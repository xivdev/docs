# Particles

Particles are the visible component of a VFX, and are created exclusively by emitters. They are similar to emitters in that they can be positioned in 3D space.

There are several types of particles:

* Decal
* Decal Ring
* Disc
* Laser
* Light Model
* Line
* Model
* Parameter
* Polygon
* Polyline \(line made of [triangles](https://www.codeproject.com/Articles/226569/Drawing-polylines-by-tessellation)\)
* Powder \(used for small particles, such as the dust which some weapons create\)
* Windmill
* Quad \(a 1x1 square\)

Particles can have textures mapped onto them using several different types of nodes \(covered later\).

## Simple Animations

Sometimes, a particle does not require complex animations, and can use the `SimpleAnimations` node instead \(in order for it to work, the `SimpleAnimationsEnabled` [attribute ](https://github.com/0ceal0t/Dalamud-VFXEditor/blob/main/AVFXLib/Models/Particle/AVFXParticle.cs#L47])must be `True`\) This is often used for `Powder` particles, which often have very basic animations due to their size and number.

## Particle Textures

There are several types of texture nodes which can be applied to a particle. Most texture nodes will have a `TextureIndex`. This determines which texture will be used as a color, normal map, etc. `TextureColor1` is especially important as it has `MaskTextureIndex`, which determines which parts of the particle will be transparent.

Most texture nodes will also have a `UVSetIndex` \(UV Sets are discussed later\).

## UV Sets

UV Sets are contained within particles, and are used to manipulate textures. This primarily involves scaling, rotating, and offsetting a texture. For example, most aura or fire VFXs will use a UV Set to animate a texture so that it "scrolls" across the particle, creating the illusion of a moving flame or energy aura.

