package bep_c.measurementapp;

public enum PacketType {
	INVALID,
	SETUP,
	ACK_SETUP,
	START_STREAMING,
	STOP_STREAMING,
	ACK_STOP,
	STREAM_DATA,
	ORIENTATION_UPDATE;

	// convert a byte from a packet to its associated PacketType
	public static PacketType fromByte(byte idx) {
		switch(idx) {
			case 1:  return SETUP;
			case 2:  return ACK_SETUP;
			case 3:  return START_STREAMING;
			case 4:  return STOP_STREAMING;
			case 5:  return ACK_STOP;
			case 6:  return STREAM_DATA;
			case 7:  return ORIENTATION_UPDATE;
			default: return INVALID;
		}
	}

	public static byte toByte(PacketType type) {
		switch(type) {
			case SETUP:	         return 1;
			case ACK_SETUP:          return 2;
			case START_STREAMING:    return 3;
			case STOP_STREAMING:     return 4;
			case ACK_STOP:           return 5;
			case STREAM_DATA:        return 6;
			case ORIENTATION_UPDATE: return 7;
			default:                 return 0;
		}	
	}
}
