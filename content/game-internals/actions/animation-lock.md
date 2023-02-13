---
description: >-
  Animation lock is an internal timer that player has to wait certain amount of
  time before they are allowed to use any actions.
---

# Animation Lock

Animation lock is an internal timer that player has to wait certain amount of time before they are allowed to use any actions.

## Basics

* Timer counts toward zero. (i.e. it represents remaining time)
* Many GCDs have 0.1s animation lock. This timer is while casting. It is resumed after player finishes casting on client side.

{% embed url="https://vault01.minoost.com/media/836da203-5984-4b36-8ff1-4b7f417185eb/ddb74582-5a4b-4ee6-9eed-8c2c3ce95dad.mp4" %}

* oGCDs and instant skills have 0.5s initial animation lock.
* Server can also set animation lock in response to actions used from the client. (usually by the packet commonly called "effect packet") However, it simply **discards** any previous timer running. Therefore, game does not compensate for player's ping. (i.e. time already spent during initial animation lock)
* You can't target ground while animation lock is active.

{% embed url="https://vault01.minoost.com/media/836da203-5984-4b36-8ff1-4b7f417185eb/bf3754c5-b251-4bf1-84b4-52deef72e75f.mp4" %}

When those three above combined, it can greatly deter game-play experience in certain condition. This will be discussed below.

## Properties

* Some actions like limit break, foods and duty actions may lock for different amount of time. For example, movement skill locks for 0.8 seconds and items have 2.0 seconds.

{% embed url="https://vault01.minoost.com/media/836da203-5984-4b36-8ff1-4b7f417185eb/2c9923d2-3b4b-47d2-859b-04fc544474bc.mp4" %}

### Clipping GCD

Since animation lock from the server overwrites curent animation lock to new value, it is this reason why double weaving between GCDs extremely unliable when player is connected to the datacentre across continent.

### Hardcasting Swiftcast

* If the client fail to receive response during initial animation lock, client is allowed to use next action. TODO.

{% embed url="https://vault01.minoost.com/media/836da203-5984-4b36-8ff1-4b7f417185eb/451948de-c958-4954-98db-2fd4586b9899.mp4" %}

While Swiftcast is one of notorious offender, this property is not limited to Swiftcast only. For example, Red Mage's Dualcast just works same as hardcasting Swiftcast.

### Cancelling Animation Lock

TODO: rescue lb3

TODO: it is possible to cancel oGCD 0.6s animlock by letting GCD overwrites it on high ping environment. (something something related to hardcasting swiftcast)
