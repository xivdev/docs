# Binders

Binders determine where a vfx should be created, and its tracking behavior \(should it follow a moving character\).

There are several types of binders:

* Point \(the most common, attach to a character, for example\)
* Camera
* Spline
* Linear

Binders can be attached to caster or target, and have several "property" fields. Properties have the attribute `BinderPointId`, which allows a vfx to be bound to a specific point on a model \(such as at the hilt of a sword\). Binder points are specified in the skeleton's `.mdl` file, although this is not well-understood.

