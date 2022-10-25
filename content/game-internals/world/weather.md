# Weather

In most zones, weather is pseudorandom and can be derived from the current time. Each zone has a weather table, which contains the possible weather states for the zone and the stacked probability of that weather being active.

## Target value

The value that the pseudorandom number generator produces is referred to as the **target value**. This value can be calculated deterministically for any given instant. It will always be in the range `[0, 99]`.

### Calculation

Given a UNIX timestamp `unixSeconds`:

```c
int32_t CalculateTarget(int32_t unixSeconds) {
    // Get Eorzea hour for weather start
    int32_t bell = unixSeconds / 175;

    // For these calculations, 16:00 is 0, 00:00 is 8 and 08:00 is 16.
    // This rotates the time accordingly and holds onto the leftover time
    // to add back in later on.
    uint32_t increment = ((uint32_t)(bell + 8 - (bell % 8))) % 24;

    // Take Eorzea days since the unix epoch
    uint32_t totalDays = (uint32_t)(unixSeconds / 4200);

    uint32_t calcBase = (totalDays * 0x64) + increment;
    uint32_t step1 = (calcBase << 0xB) ^ calcBase;
    uint32_t step2 = (step1 >> 8) ^ step1;
    return (int32_t)(step2 % 0x64);
}
```

## Weather lookup

Once the target value has been calculated, the `WeatherRate` row for the current `TerritoryType` is retrieved. The rates of each entry in the row are accumulated until the target value is less than the current value of the rate accumulator. At this point, the current weather rate entry is selected, and the corresponding weather ID denotes the `Weather` row that should be used.

### Retrieving the weather for a zone by zone name

Territories can be queried by name using their `PlaceName` attribute. Territories have a `WeatherRate` that describes the weather rate row they use. Using the process described above, the current `Weather` being used can be determined.

## Remarks

Some zones, such as the original version of Diadem, use the [WeatherChange](https://github.com/SapphireServer/Sapphire/blob/aef56c9f336473472147cdeabc0cbc97f440f023/src/common/Network/PacketDef/Zone/ServerZoneDef.h#L1583-L1587) message to control what weather the player experiences. It is not known what zones currently use this message for weather.