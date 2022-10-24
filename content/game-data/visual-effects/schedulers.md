# Schedulers

Every VFX has exactly 1 Scheduler.

Schedulers control when Timelines are started, and have 2 components: a list of items, and a list of triggers. A scheduler can have an arbitrary number of items, but must have 12 triggers. Both items and triggers follow the same format:

```text
bool Enabled
int StartTime
int TimelineIndex
```

## Triggers

What the triggers represent is not understood, but they are probably each for a specific type of action, such as sheathing a weapon, getting hit, etc. Unused triggers have `TimelineIndex = -1`.

## Items

Items function like triggers, but will start automatically without any additional input. If you are having trouble viewing a VFX, such as one which was originally used for a cutscene, it can often be useful to disable all the triggers, and instead exclusively use items to start timelines.
