public enum PacketType
{
	INVALID, 
	SETUP, 
	ACK_SETUP, 
	START_STREAMING, 
	STOP_STREAMING, 
	ACK_STOP, 
	STREAM_DATA, 
	ORIENTATION_UPDATE;
	
	public static PacketType fromByte(byte idx)
	{
		switch (idx)
		{
		case 1: return SETUP;
		case 2: return ACK_SETUP;
		case 3: return START_STREAMING;
		case 4: return STOP_STREAMING;
		case 5: return ACK_STOP;
		case 6: return STREAM_DATA;
		case 7: return ORIENTATION_UPDATE;
		default: return INVALID;
		}
	}
	
	public byte toByte()
	{
	switch (this){
		case SETUP: 			return 1;
		case ACK_SETUP:			return 2;
		case START_STREAMING:	return 3;
		case STOP_STREAMING: 	return 4;
		case ACK_STOP: 			return 5;
		case STREAM_DATA:		return 6;
		case ORIENTATION_UPDATE:return 7;
		default: 				return 0; // invalid
	}
	}
}

/* 1: SETUP: set up initial parameters and request identifier
Contents:
	- 4 bytes sample rate in Hz
	- 4 bytes block length in bytes

2: ACK_SETUP: acknowledge SETUP packet and send identifier
	- 4 byte: length of HW identifier
	- string: hardware identifier of phone

3: START_STREAMING: command to start streaming audio data
	- audio source: enumeration stored in 1 byte:
		- Follows Android values

4: STOP_STREAMING: command to stop streaming audio data
	- No contents

5: ACK_STOP: acknowledgement of stop command
	- No contents

6: STREAM_DATA: packet containing audio data
	- Block length (see above) * 16 bit words

7: ORIENTATION_UPDATE: packet containing updated orientation data
	- 4 byte floating point azimuth
	- 4 byte floating point elevation
	- 1 byte Flag indicating device is moving (1) or not (0) */