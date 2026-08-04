#!/usr/bin/env python3
"""Test MusicBeam's Art-Net effect selection by sending ArtDMX frames.

Enable the "Art-Net (DMX)" toggle in MusicBeam first, then:

    python3 artnet_test.py 3               select effect 3
    python3 artnet_test.py 0               blackout / no effect
    python3 artnet_test.py demo            cycle through all effects, then blackout
    python3 artnet_test.py 3 192.168.1.20  send to another machine
"""
import socket
import sys
import time

EFFECT_COUNT = 11  # effect indices 0..10, 0 = Blackout


def send(value, host):
    packet = bytearray(b"Art-Net\x00")
    packet += (0x5000).to_bytes(2, "little")  # OpCode: ArtDMX
    packet += (14).to_bytes(2, "big")         # protocol version
    packet += bytes([0, 0])                   # sequence, physical
    packet += bytes([0, 0])                   # universe 0
    packet += (1).to_bytes(2, "big")          # one DMX channel
    packet += bytes([value])                  # channel 1 = effect index
    socket.socket(socket.AF_INET, socket.SOCK_DGRAM).sendto(packet, (host, 6454))
    print(f"sent effect index {value} to {host}")


if len(sys.argv) < 2:
    sys.exit(__doc__)
host = sys.argv[2] if len(sys.argv) > 2 else "127.0.0.1"
if sys.argv[1] == "demo":
    for value in list(range(EFFECT_COUNT)) + [0]:
        send(value, host)
        time.sleep(2)
else:
    send(int(sys.argv[1]), host)
