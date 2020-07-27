---
description: >-
  Animation lock is an internal timer that player has to wait certain amount of
  time before they are allowed to use any actions.
---

# Animation Lock

Animation lock is an internal timer that player has to wait certain amount of time before they are allowed to use any actions.

## Basics <a id="052a4d12-e358-4744-be6f-a9d48141ceaf"></a>

The timer is the number of seconds until the animation lock is up, stored as a float. This has an additional flaw due to how the game tracks time: lower framerates will generally result in a longer animation lock time because the timer resolution is significantly lower.

Many GCDs have 0.1s animation lock. This timer is while casting. It is resumed after player finishes casting on client side.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736122305918402580/gcd.mp4" %}

* oGCDs and instant skills have 0.5s initial animation lock.
* Server can also set animation lock in response to actions used from the client \(usually from the [effect packet](https://github.com/SapphireServer/Sapphire/blob/d60b68cfa2d9800bb4734f23247060ad00d385f3/src/common/Network/PacketDef/Zone/ServerZoneDef.h#L529-L568)\). However, it simply **discards** any previous timer running. Therefore, game does not compensate for player's ping. \(i.e. time already spent during initial animation lock\)
* You can't place ground targeted actions while animation lock is active.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736121156658135082/ground\_lock.mp4" %}

When those three conditions above are combined, it can greatly impact gameplay experience.

## Properties <a id="9dd6abc5-3539-4645-b89f-602e1854310d"></a>

Some actions like limit break, foods and duty actions may lock for different amount of time. For example, movement skill locks for 0.8 seconds and items have 2.0 seconds.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736121121509736528/bll.mp4" %}

### Clipping GCD <a id="79353019-839a-4db5-96b0-a5be7d0addc9"></a>

Since animation lock from the server overwrites current animation lock to new value, it is this reason why double weaving between GCDs extremely unreliable when player is connected to the data centre across a continent or on a completely different continent.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736121024042500176/clip\_g.mp4" %}

### Hardcasting Swiftcast <a id="c3ecce6e-2a46-4eff-8169-1d44d7e2fb40"></a>

* If the client fail to receive response during initial animation lock, client is allowed to use next action. TODO.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736136653277757460/hardswift.mp4" %}

While swiftcast is one of notorious offender, this property is not limited to swiftcast only. For example, red mage's dualcast just works same as hardcasting swiftcast.

### Cancelling Animation Lock <a id="6aa269fa-bef7-411d-8bab-f1cf7381b00f"></a>

TODO: rescue lb3

TODO: it is possible to cancel oGCD 0.6s animlock by letting GCD overwrites it on high ping environment. \(something something related to hardcasting swiftcast\)

