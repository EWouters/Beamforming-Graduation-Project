package bep_c.measurementapp;

// HW dependencies
import android.hardware.SensorManager;
import android.hardware.Sensor;
import android.hardware.SensorEventListener;
import android.hardware.SensorEvent;

// Android dependencies
import android.os.IBinder;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import android.content.Context;
import android.content.Intent;

import android.util.Log;

import android.app.Service;
import android.app.Notification;
import android.app.NotificationManager;

import android.widget.Toast;

// The main networking thread
public class OrientationThread extends Thread implements SensorEventListener {
	protected static final String LOG_TAG = "OrientationThread";

	public static final int UPDATE_INTERVAL = 1000;

	protected NetworkInterfaceThread parent;
	protected float[] gravity, geomagnetic;
	protected boolean mRunning;

	// SensorEventListener methods -- sensor handling
	@Override
	public final void onAccuracyChanged(Sensor sensor, int accuracy) {
		// TODO: send moved event on low sensor accuracy?
	}

	@Override
	public final synchronized void onSensorChanged(SensorEvent event) {
		Log.d(LOG_TAG, "sensor update!");
		if(event.sensor.getType() == Sensor.TYPE_MAGNETIC_FIELD)
			geomagnetic = event.values;
		else if(event.sensor.getType() == Sensor.TYPE_GRAVITY)
			gravity = event.values;
	}

	public OrientationThread(NetworkInterfaceThread parent) {
		this.parent = parent;
	}

	public void run() {
		mRunning = true;

		Log.d(LOG_TAG, "Orientation thread starting");

		float[] R = new float[9], I = new float[9];	// matrices for orientation computations
		float[] orientation = new float[3];		// computed orientation angles

		// find sensors
		SensorManager manager = (SensorManager) parent.mService.getSystemService(Context.SENSOR_SERVICE);
		Sensor magnetometer = manager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD);
		Sensor gravitometer = manager.getDefaultSensor(Sensor.TYPE_GRAVITY);

		if(magnetometer == null || gravitometer == null) {
			// not enough sensors so can't estimate our position, TODO: handle
			Log.d(LOG_TAG, "Cannot estimate orientation: not enough sensors");
			return;
		}

		// register ourselves as a sensor listener
		manager.registerListener(this, magnetometer, SensorManager.SENSOR_DELAY_NORMAL);
		manager.registerListener(this, gravitometer, SensorManager.SENSOR_DELAY_NORMAL);

		// send periodic updates
		while(mRunning) {
			try {
				synchronized(this) {
					wait(UPDATE_INTERVAL);
				}
			} catch(InterruptedException e) {
				// do nothing
			}
			// compute orientation
			boolean invalid;
			synchronized(this) {
				invalid = manager.getRotationMatrix(R, I, gravity, geomagnetic);
			}
			manager.getOrientation (R, orientation);
			parent.updateOrientation(orientation[0], orientation[1], orientation[2], !invalid);
		}

		// clean up
		manager.unregisterListener(this);
		Log.d(LOG_TAG, "Orientation thread stopping");
	}

	public void doStop() {
		mRunning = false;
		try {
			join();
		} catch(InterruptedException e) {
			// ignore
			Log.d(LOG_TAG, "Join interrupted");
		}
	}
}
