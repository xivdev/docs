---
description: >-
  Animation lock is an internal timer that player has to wait certain amount of
  time before they are allowed to use any actions.
---

# Animation Lock

## Notable observations

* TODO: GCD -&gt; 0.1s

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736122305918402580/gcd.mp4" %}

* TODO: overwrite something something clipping server ping that
* that means playing on datacentre with high ping can incur additional time for lock. This makes double-weaving between GCDs extremely unliable when connected to inter-continent datacentre.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736121024042500176/clip\_g.mp4" %}

* TODO: &lt;stuff&gt; ...that is until  &lt;stuff&gt; at which point next cast won't consume swiftcast and go hardcast instead.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736136653277757460/hardswift.mp4" %}





* You can't place a ground target while timer is active.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736121156658135082/ground\_lock.mp4" %}

* Some actions like Limit Break may have different amount of time for lock. For example, movement skill locks for 0.8 seconds.

{% embed url="https://cdn.discordapp.com/attachments/141479244067897344/736121121509736528/bll.mp4" %}



