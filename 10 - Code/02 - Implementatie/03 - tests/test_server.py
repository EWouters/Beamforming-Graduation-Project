from __future__ import print_function

import sys
import argparse
import socket
import math
import struct
import wave

# constants
SERVER_PORT = 1337

PACKET_SETUP              = 0x01
PACKET_ACK_SETUP          = 0x02
PACKET_START_STREAMING    = 0x03
PACKET_STOP_STREAMING     = 0x04
PACKET_ACK_STOP           = 0x05
PACKET_STREAM_DATA        = 0x06
PACKET_ORIENTATION_UPDATE = 0x07

# read in config
parser = argparse.ArgumentParser(description='Receive and record audio streams')
parser.add_argument('-p', '--port',               metavar='N', type=int,   default=1337,  help='Port to listen on')
parser.add_argument('-r', '--rate',               metavar='R', type=int,   default=48000, help='Sample rate (in Hz)')
parser.add_argument('-s', '--audio-source',       metavar='S', type=int,   default=1,     help='The Android audio source to use')
parser.add_argument('-S', '--stereo',             action='store_true',     default=False, help='Whether to record in stereo')
parser.add_argument('-n', '--num-recordings',     metavar='N', type=int,   default=3,     help='Number of recordings')
parser.add_argument('-l', '--recording-duration', metavar='T', type=float, default=3.,    help='Recording duration (in seconds; rounded up)')
parser.add_argument('-b', '--block-duration',     metavar='T', type=float, default=0.01,  help='Sample block duration (in seconds; rounded up)')

args = parser.parse_args()

block_length   = int(math.ceil(args.block_duration * args.rate)) * (2 if args.stereo else 1)
num_blocks     = int(math.ceil(args.recording_duration / args.block_duration))

print("Recording %d runs (%.3f s) of %d blocks (%.3f s) of %d %s samples (%.3f s) at %d Hz" % (args.num_recordings, (args.num_recordings * num_blocks * block_length) / float(args.rate),
                                                                                            num_blocks, (num_blocks*block_length)/float(args.rate),
                                                                                            block_length, "stereo" if args.stereo else "mono", block_length/float(args.rate), args.rate))

# open listen socket
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.bind(("0.0.0.0", SERVER_PORT))
serversocket.listen(1)

print("Now listening on port %d" % SERVER_PORT)

def real_recv(sock, n):
    b = ""
    while len(b) < n:
        b += sock.recv(n-len(b))
    return b

(clientsocket, address) = serversocket.accept()

# transmit setup packet
clientsocket.send(struct.pack("!BiiB", PACKET_SETUP, args.rate, block_length,(1 if args.stereo else 0)))

# receive reply
ack_raw = real_recv(clientsocket, 5)
print("Received %d bytes" % len(ack_raw))
ack_hdr = struct.unpack("!Bi", ack_raw)

assert ack_hdr[0] == PACKET_ACK_SETUP, "Received packet %02X instead of ACK_SETUP (%02X)" % (ack_hdr[0], PACKET_ACK_SETUP)
print("HWID is %d bytes" % ack_hdr[1])
hwid = ""
for i in range(ack_hdr[1]/2):
    c = struct.unpack("!H", real_recv(clientsocket, 2))
    hwid += chr(c[0])


print("Received ACK, HWID = %s" % hwid)

for recording in range(args.num_recordings):
    # open .wav file
    filename = "test%d.wav" % recording
    print("Recording to %s" % filename)
    outfile = wave.open(filename, "wb")
    outfile.setnchannels(1 if args.stereo else 2)
    outfile.setsampwidth(2)
    outfile.setframerate(args.rate)

    # transmit start streaming
    clientsocket.send(struct.pack("!BB", PACKET_START_STREAMING, args.audio_source))

    # receive samples
    for block in range(num_blocks):
        print('-', end='')
        if block%8 == 0:
            print(' ', end='')
            sys.stdout.flush()
        packet_type = struct.unpack("!B", real_recv(clientsocket, 1))[0]
        assert packet_type == PACKET_STREAM_DATA, "Received packet %02X instead of STREAM_DATA (%02X)" % (packet_type, PACKET_STREAM_DATA)
        samples = real_recv(clientsocket, block_length*2)
        outfile.writeframes(samples)
    print('\n', end='')

    # transmit stop streaming
    clientsocket.send(struct.pack("!B", PACKET_STOP_STREAMING))

    # receive reply, get rid of any leftover stream data
    while True:
        packet_type = struct.unpack("!B", real_recv(clientsocket, 1))[0]
        if packet_type == PACKET_STREAM_DATA:
            samples = real_recv(clientsocket, block_length*2)
            outfile.writeframes(samples)
        else:
            break

    # close .wav file
    outfile.close()

    assert packet_type == PACKET_ACK_STOP, "Received packet %02X instead of ACK_STOP (%02X)" % (packet_type, PACKET_ACK_STOP)

clientsocket.close()

serversocket.close()

print("All done")
