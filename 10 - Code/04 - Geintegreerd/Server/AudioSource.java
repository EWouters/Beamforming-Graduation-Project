public enum AudioSource
{
	DEFAULT,
	MIC,
	VOICE_UPLINK,
	VOICE_DOWNLINK,
	VOICE_CALL,
	CAMCORDER,
	VOICE_RECOGNITION,
	VOICE_COMMUNICATION,
	REMOTE_SUBMIX;
	
	public byte toByte()
	{
	switch (this){
		case CAMCORDER: 			return 5;
		case DEFAULT:				return 0;
		case MIC:					return 1;
		case REMOTE_SUBMIX: 		return 8;
		case VOICE_CALL: 			return 4;
		case VOICE_COMMUNICATION:	return 7;
		case VOICE_DOWNLINK:		return 3;
		case VOICE_RECOGNITION: 	return 6;
		case VOICE_UPLINK: 			return 2;
		default: 					return 0;
	}
	}
}