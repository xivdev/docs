# RSF

RSF is very similar to [RSV](rsv.md) except it works on file level.

### Pseudocode

The procedure to generate a RSF file is as follows:

```python
def create_rsf(plaintext):
    deflated_bytes = zlib.compress(plaintext, level=9)
    
    # Server stores this part and will send it to the client when zoning-in
    header = deflated_bytes[:64]
    
    # Client stores this part
    body = deflated_bytes[64:]
```
