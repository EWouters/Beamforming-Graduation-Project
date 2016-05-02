package bep_c.measurementapp;

// The different states the recording thread can be in.
public enum NetworkInterfaceThreadState {
	DISCONNECTED,
	SETUP,
	IDLE,
	STREAMING;
}

