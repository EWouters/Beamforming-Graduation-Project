package bep_c.measurementapp;

import java.nio.ByteBuffer;
import java.lang.Thread;

// Android dependencies
import android.os.IBinder;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import android.util.Log;

import android.media.AudioRecord;
import android.media.AudioFormat;

// The main networking thread
public class AudioThread extends Thread {
	protected static final String LOG_TAG = "AudioThread";

	protected static final int BUFFER_SLACK = 4;	// the factor by which the AudioRecord buffer is larger than the minimum

	protected NetworkInterfaceThread parent;

	protected AudioRecord recorder;
	protected int sampleRate;	// the sample rate
	protected int blockSize;	// the buffer size used to assemble the packet, in bytes
	protected int audioBufferSize;	// the buffer used to read from the AudioRecord instance
	protected boolean stereo;	// whether we are recording in stereo (true) or mono (false)
	protected ByteBuffer network_buffer;
	protected Boolean isRunning;

	public AudioThread(NetworkInterfaceThread parent) {
		super();
		this.parent = parent;
	}

	@Override
	public void run() {
		isRunning = true;

		while(isRunning) {
			// attempt to read a full audio buffer size
			int read_size = (network_buffer.remaining() > audioBufferSize) ? audioBufferSize : network_buffer.remaining();

			int bytes_read = recorder.read(network_buffer, read_size);
			if(bytes_read < 0) {
				Log.d(LOG_TAG, String.format("AudioRecorder.read() failed: got value %d < 0", bytes_read));
			} else {
				network_buffer.position(network_buffer.position() + bytes_read);		// manually increment buffer position

				if(network_buffer.remaining() == 0) {
					// we have a whole buffer!
					network_buffer.flip();
					parent.transmitSamples(network_buffer);
					network_buffer.clear();
				}
			}
		}
	}

	public void setup(int sampleRate, int blockSizeInWords, boolean stereo) {
		this.sampleRate = sampleRate;
		this.blockSize  = blockSizeInWords*2;	// we measure block size in bytes, not (16-bit) words
		this.stereo     = stereo;
	}

	public boolean startStreaming(int audioSource) {
		// just restart the thread if already running
		if(isAlive()) {
			stopStreaming();
		}

		int channelConfig = stereo ? AudioFormat.CHANNEL_IN_STEREO : AudioFormat.CHANNEL_IN_MONO;
		// TODO: strike balance between buffer sizes better
		audioBufferSize = AudioRecord.getMinBufferSize(sampleRate, channelConfig, AudioFormat.ENCODING_PCM_16BIT) * BUFFER_SLACK;
		//audioBufferSize = sampleRate;	// 1s buffer
		Log.d(LOG_TAG, String.format("Audio buffer size: %d samples", audioBufferSize));

		try {
			recorder = new AudioRecord((int)audioSource, sampleRate, channelConfig, AudioFormat.ENCODING_PCM_16BIT, audioBufferSize);
		} catch(IllegalArgumentException e) {
			Log.d(LOG_TAG, String.format("Illegal argument exception while constructing AudioRecord instance: %s", e.toString()));
			return false;
		}

		if(recorder.getState() != AudioRecord.STATE_INITIALIZED) {
			Log.d(LOG_TAG, String.format("AudioRecord not initialized"));
			return false;
		}

		// the AudioRecord can only record to a direct buffer
		network_buffer      = ByteBuffer.allocateDirect(blockSize);

		// let's go!
		recorder.startRecording();
		start();

		return true;
	}

	public void stopStreaming() {
		if(recorder != null && recorder.getRecordingState() == AudioRecord.RECORDSTATE_RECORDING)
			recorder.stop();
		isRunning = false;
		try {
			join();
		} catch(InterruptedException e) {
			// ignore
			Log.d(LOG_TAG, "Join interrupted");
		}
		recorder.release();
		recorder = null;
	}
}
