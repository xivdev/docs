# Emitters

Emitters, as their name suggests, emit objects \(either other emitters, or particles\). They are triggered through timeline items, and can be moved in 3D space just like any other object. Unlike particles, emitters themselves are not visible. Emitters can also trigger a sound to play.

When an emitter creates another object, it can influence the properties of its child \(such as color, scale, or position\). Whether or not an emitter will influence its children is determined by parameters such as `InfluenceCoordScale`.

There are several types of emitters:

* Point
* Cone
* Cone Model \(like a cone, but is subdivided across its axes\)
* Sphere
* Sphere Model
* Model \(any model, where objects can be emitted on its vertices\)
