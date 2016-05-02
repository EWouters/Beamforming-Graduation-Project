package bep_c.measurementapp;

// Networking dependencies
import java.net.Socket;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.nio.ByteBuffer;

import java.io.IOException;
import java.io.InterruptedIOException;
import java.io.EOFException;
import java.net.UnknownHostException;

// Android dependencies
import android.os.IBinder;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import android.net.wifi.WifiManager;
import android.net.wifi.WifiInfo;

import android.content.Context;
import android.content.Intent;

import android.util.Log;

import android.app.Service;

import android.widget.Toast;

// The main networking thread
public class NetworkInterfaceThread extends Thread {
	// constants
	protected static final String LOG_TAG = "NetworkInterfaceThread";

	// values passed into thread
	public RecordService mService;
	protected String mHost;
	protected int mPort;
	protected int sampleRate, blockLength;
	protected boolean stereo;

	// thread state
	protected Socket mSocket;
	protected NetworkInterfaceThreadState mState;
	DataOutputStream socketOutputStream;
	protected String mHWID;
	protected OrientationThread mOrientationThread;
	protected AudioThread audioThread;

	public static final String getUID(Context c) {
		WifiManager manager = (WifiManager)(c.getSystemService(Context.WIFI_SERVICE));
		WifiInfo info       = manager.getConnectionInfo();
		return info.getMacAddress();
	}

	public NetworkInterfaceThread(RecordService service, String host, int port) {
		mService    = service;
		mHost       = host;
		mPort       = port;
		mState      = NetworkInterfaceThreadState.DISCONNECTED;
		sampleRate  = -1;
		blockLength = -1;

		// get hardware ID
                audioThread = null;
		mHWID       = getUID(mService);
	}

	protected final void showToast(final String msg, final int duration) {
		mService.runOnUiThread(new Runnable() {
			public void run() { Toast.makeText(mService, msg, duration).show(); }
		} );
	}

	public synchronized void transmitSamples(ByteBuffer samples) {
		try {
			socketOutputStream.writeByte(PacketType.toByte(PacketType.STREAM_DATA));
			socketOutputStream.write(samples.array(), samples.arrayOffset(), samples.remaining());
		} catch(IOException e) {
			// FIXME
			// Log.w(LOG_TAG, Log.getStackTraceString(e));
		}
	}

	public synchronized void updateOrientation(float azimuth, float pitch, float roll, boolean isMoving) {
		if((mState != NetworkInterfaceThreadState.STREAMING) && (mState != NetworkInterfaceThreadState.IDLE))
			return;	// only send updates when streaming

		try {
			socketOutputStream.writeByte(PacketType.toByte(PacketType.ORIENTATION_UPDATE));
			socketOutputStream.writeFloat(azimuth);
			socketOutputStream.writeFloat(pitch);
			socketOutputStream.writeFloat(roll);
			socketOutputStream.writeByte(isMoving?1:0);

			Log.d(LOG_TAG, String.format("Orientation update: %7.3f, %7.3f, %7.3f, %s", azimuth, pitch, roll, isMoving?"moving":"not moving"));
		} catch(IOException e) {
			Log.w(LOG_TAG, Log.getStackTraceString(e));
		}
	}

	protected synchronized void ack_setup(String hardware_id) {
		try {
			socketOutputStream.writeByte(PacketType.toByte(PacketType.ACK_SETUP));	// packet type
			socketOutputStream.writeInt(hardware_id.length()*2);			// length of ID
			socketOutputStream.writeChars(hardware_id);				// ID
		} catch(IOException e) {
			Log.w(LOG_TAG, Log.getStackTraceString(e));
		}
	}

	protected synchronized void ack_stop() {
		try {
			socketOutputStream.writeByte(PacketType.toByte(PacketType.ACK_STOP));	// packet type
		} catch(IOException e) {
			Log.w(LOG_TAG, Log.getStackTraceString(e));
		}
	}

	public synchronized NetworkInterfaceThreadState getConnectionState() {
		return mState;
	}

	protected synchronized void changeState(NetworkInterfaceThreadState newState) {
		mState = newState;
		mService.updateNotification();
	}

	protected void setup(int sampleRate, int blockLength, boolean stereo) {
		if(mState != NetworkInterfaceThreadState.SETUP)
			return;

                // store values for creating the audio thread later
                this.sampleRate  = sampleRate;
                this.blockLength = blockLength;
		this.stereo      = stereo;

		changeState(NetworkInterfaceThreadState.IDLE);
		ack_setup(mHWID);

		Log.i(LOG_TAG, String.format(mService.getString(R.string.service_setup_done), sampleRate, blockLength));
	}

	protected void startStreaming(byte audioSource) {
		if(mState != NetworkInterfaceThreadState.IDLE)
			return;

                // create a new audio thread!
		audioThread = new AudioThread(this);
		audioThread.setup(sampleRate, blockLength, stereo);
		boolean success = audioThread.startStreaming(audioSource);
		if(success) {
			changeState(NetworkInterfaceThreadState.STREAMING);

			showToast(String.format(mService.getString(R.string.service_start_streaming), audioSource), Toast.LENGTH_SHORT);
			Log.i(LOG_TAG, String.format(mService.getString(R.string.service_start_streaming), audioSource));
		}
	}

	protected void stopStreaming() {
		if(mState != NetworkInterfaceThreadState.STREAMING)
			return;

		changeState(NetworkInterfaceThreadState.IDLE);
		audioThread.stopStreaming();
                audioThread = null;
		ack_stop();
		showToast(mService.getString(R.string.service_stop_streaming), Toast.LENGTH_SHORT);
		Log.i(LOG_TAG, mService.getString(R.string.service_stop_streaming));
	}

	public void run() {
		// set up the connection
		try {
			DataInputStream socketInputStream;
			try {
				mSocket = new Socket(mHost, mPort);
				socketInputStream  = new DataInputStream(mSocket.getInputStream());
				socketOutputStream = new DataOutputStream(mSocket.getOutputStream());
			} catch(UnknownHostException e) {
				showToast(mService.getString(R.string.service_unknown_host), Toast.LENGTH_LONG);
				Log.w(LOG_TAG, Log.getStackTraceString(e));
				stopForeground();
				return;
			}

			// start the orientation thread
			mOrientationThread = new OrientationThread(this);
			mOrientationThread.start();

			// enter the main loop
			changeState(NetworkInterfaceThreadState.SETUP);

			Log.i(LOG_TAG, "entering main loop");
			while(mState != NetworkInterfaceThreadState.DISCONNECTED) {
				// attempt to receive a packet
				try {
					byte typeByte = socketInputStream.readByte();
					PacketType type = PacketType.fromByte(typeByte);
					Log.d(LOG_TAG, "received packet");

					// demultiplex
					switch(type) {
						case SETUP:
							// The setup packet contains a 4-byte sample rate and a 4-byte block length
							Log.i(LOG_TAG, "in setup");
							int sampleRate  = socketInputStream.readInt();
							int blockLength = socketInputStream.readInt();
							boolean stereo  = (socketInputStream.readByte() == 1) ? true : false;
							setup(sampleRate, blockLength, stereo);
							break;

						case START_STREAMING:
							// The 'start streaming' packet contains a single byte specifying the audio source to use
							Log.d(LOG_TAG, "starting stream");
							byte audioSource = socketInputStream.readByte();
							startStreaming(audioSource);
							break;

						case STOP_STREAMING:
							Log.d(LOG_TAG, "stopping stream");
							// The 'stop streaming' packet contains no data
							stopStreaming();
							break;

						default:	// fallback -- not a packet type we can do anything with
							Log.d(LOG_TAG, String.format("unknown packet type %d", typeByte));
							continue;
					}
				} catch(InterruptedIOException e) {
					// timeout occurred, ignore
				}
			}
		} catch(EOFException e) {
			showToast(mService.getString(R.string.service_stopping), Toast.LENGTH_SHORT);
			Log.w(LOG_TAG, mService.getString(R.string.service_stopping));
		} catch(IOException e) {
			showToast(String.format(mService.getString(R.string.service_ioexception), e.getLocalizedMessage()), Toast.LENGTH_LONG);
			Log.w(LOG_TAG, Log.getStackTraceString(e));
		}

		Log.i(LOG_TAG, "exiting main loop");
		doStop();

		stopForeground();
		mSocket = null;
	}

	public void stopForeground() {
		mService.runOnUiThread(new Runnable() {
				public void run() { mService.stopForeground(true); }
			} );
	}

	public void doStop() {
		if(mState == NetworkInterfaceThreadState.DISCONNECTED) return;	// not running so can't stop
		try {
			// stop orientation thread
			if(mOrientationThread != null)
				mOrientationThread.doStop();

			// stop audio thread
			if(audioThread != null)
				audioThread.stopStreaming();

			// clean up
			mSocket.close();
		} catch(IOException e) {
			Log.w(LOG_TAG, Log.getStackTraceString(e));
		}

		changeState(NetworkInterfaceThreadState.DISCONNECTED);
	}
}
