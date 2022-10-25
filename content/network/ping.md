---
description: Internal ping calculation
---

# Ping

1. The client uses [QueryPerformanceCounter](https://learn.microsoft.com/en-us/windows/win32/api/profileapi/nf-profileapi-queryperformancecounter) to generate an arbitrary timestamp, which it converts roughly into milliseconds by dividing it by 10,000.
2. An IPC message is sent by the client which includes the timestamp encoded as a 32-bit integer value.
3. An IPC message is sent back by the server with the same timestamp.
4. The client generates a new timestamp, divides it by 10,000, and then computes the difference between them to get the RTT for the connection.

## Pseudocode

```c
void SendPingRequest() {
    int64_t t;
    PingRequest req;
    QueryPerformanceCounter(&t);
    req.timestamp = (int32_t)(t / 10000);
    SendMessage(req);
}

int32_t HandlePingResponse(PingResponse resp) {
    int64_t currT;
    int32_t prevMs = resp.timestamp;
    QueryPerformanceCounter(&currT);
    int32_t currMs = (int32_t)(currT / 10000);
    return currMs - prevMs;
}
```

## Remarks

{% hint style="info" %}
Because the server copies the same timestamp into the response message as is in the request message, ping calculation can be done in a stateless manner with respect to the client.
{% endhint %}
