# BSG Rocket info#

### HTIF ###

The HTIF protocol is based on a header(64 bits) and payload(N*64 bits), where N (number of packets) is defined in the header. However, the physical layer breakdown packets in 16-bits, starting from the LSB.

### HTIF header ###

Header format (work in progress), where size = N = number of payload packets.

| [63:24]  | [23:16] | [15:4] | [3:0]  |
|:--------:|:-------:|:------:|:------:|
| csr-addr |  seqno  | size   | cmd    |

### HTIF commands ###

The fesvr protocol is based on polling and it is always initiate by the host. In other words,
the host(master) always sends requests and rocket(slave) acknowledge them.

|  type   |   cmd     |  value  |
|---------|-----------|:---------:|
request   | read mem  | 0 |
request   | write mem | 1 |
request   | read csr  | 2 |
request   | write csr | 3 |
response  | ack       | 4 |
response  | nack      | 5 |

### HTIF CSR address ###

|   CSR name  |   address  |
|-------------|------------|
CSR\_MTOHOST   | 0x0000000780 |
CSR\_MFROMHOST | 0x0000000781 |
CSR\_MRESET    | 0x0000000782 |

### HTIF polling packet ###

seqno stands for sequential number and it just a counter.

| [63:24]  | [23:16] | [15:4] | [3:0]  |
|:--------:|:-------:|:------:|:------:|
| 0x0000000780 |  seqno | 0x001 | 0x3 |

If the payload (64-bits) is different than zero, then there is something to be done.

### HTIF exit() response packet ###

Header packet

| [63:24]  | [23:16] | [15:4] | [3:0]  |
|:--------:|:-------:|:------:|:------:|
| 0x0000000780 |  seqno | 0x001 | 0x4 |

Payload packet 0x0000000000000001

After this, CSR\_MFROMHOST is set to 0x1 and rocket-reset is asserted back again by setting CSR\_MRESET to 0x1.
