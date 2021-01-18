# Timelines

A timeline consists of a list of items, and a list of clips.

Items represent the creation of an emitter, while clips represent other actions, such as deleting particles. Although clips are not well understood, the are probably used for things such as hiding a vfx when a weapon is sheathed.

## Clips

Clips must be triggered from items using the `ClipNumber` parameter. Usually, items which trigger clips will have `EmitterIndex = -1`. 

Items are also where emitters are attached to binders and effectors using `BinderIndex`, `EmitterIndex`, and `EffectorIndex`. Items which were originally used for a cutscene or background will usually have `BinderIndex = -1`, which will cause them to not be rendered on player characters, so creating a binder and setting `BinderIndex = 0` can fix this.

