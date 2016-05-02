package bep_c.measurementapp;

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
import android.app.PendingIntent;

import android.widget.Toast;

public class RecordService extends Service {
	private static final int SERVICE_NOTIFICATION_ID = 1;

	private NetworkInterfaceThread mNetworkInterfaceThread;	// the recording thread
	private Handler handler;

	@Override
	public void onCreate() {
		// Handler will get associated with the current thread, 
		// which is the main thread.
		handler = new Handler(Looper.getMainLooper());
		super.onCreate();
	}

	protected void runOnUiThread(Runnable runnable) {
		handler.post(runnable);
	}

	public void updateNotification() {
		// set up an Intent so we can run the setup app from the notification
		Intent notifyIntent = new Intent(this, SetupActivity.class);
		notifyIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
		PendingIntent notifyPendingIntent = PendingIntent.getActivity(
				this,
				0,
				notifyIntent,
				PendingIntent.FLAG_UPDATE_CURRENT
			);

		// build the notification
		Notification.Builder mBuilder =
			new Notification.Builder(this)
			.setContentTitle(getString(R.string.notification_title))
			.setSmallIcon(R.drawable.service_icon)
			.setContentIntent(notifyPendingIntent);

		switch(mNetworkInterfaceThread.getConnectionState()) {
			case DISCONNECTED:
				mBuilder.setContentText(getString(R.string.notification_disconnected));
				break;

			case SETUP:
				mBuilder.setContentText(getString(R.string.notification_setup));
				break;

			case IDLE:
				mBuilder.setContentText(getString(R.string.notification_idle));
				break;

			case STREAMING:
				mBuilder.setContentText(getString(R.string.notification_streaming));
				break;
		}
		
		Notification notification = mBuilder.build();
		((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).notify(SERVICE_NOTIFICATION_ID, notification);
	}

	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		if(mNetworkInterfaceThread == null) {
			Toast.makeText(this, R.string.service_starting, Toast.LENGTH_LONG).show();
		} else {
			Toast.makeText(this, R.string.service_restarting, Toast.LENGTH_LONG).show();
			stop();
			try {
				mNetworkInterfaceThread.doStop();
				mNetworkInterfaceThread.join();
				mNetworkInterfaceThread = null;
			} catch(InterruptedException e) {
				// do nothing, we're shutting it down anyway
			}
		}

		// run the service as a foreground service -- effectively giving a higher priority
		Notification.Builder mBuilder =
			new Notification.Builder(this)
			.setContentTitle(getString(R.string.notification_title))
			.setContentText(getString(R.string.notification_disconnected))
			.setSmallIcon(R.drawable.service_icon);

		Notification notification = mBuilder.build();
		((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).notify(SERVICE_NOTIFICATION_ID, notification);

		startForeground(SERVICE_NOTIFICATION_ID, notification);

		// get the host and port to connect to
		Bundle extras = intent.getExtras();

		if(extras == null) return START_STICKY;	// no extras passed; this should not happen

		String host = (String)extras.get(SetupActivity.HOST_KEY);
		int port = (int)extras.get(SetupActivity.PORT_KEY);

		// (re-)start the actual recording thread
		mNetworkInterfaceThread = new NetworkInterfaceThread(this, host, port);
		mNetworkInterfaceThread.start();

		return START_STICKY;
	}

	@Override
	public IBinder onBind(Intent intent) {
		// We don't provide binding, so return null
		return null;
	}

	public void stop() {
		stopForeground(true);
		if(mNetworkInterfaceThread.isAlive()) {
			Toast.makeText(this, R.string.service_stopping,    Toast.LENGTH_SHORT).show();
			mNetworkInterfaceThread.doStop();
		} else {
			Toast.makeText(this, R.string.service_not_running, Toast.LENGTH_SHORT).show();
		}
	}

	@Override
	public void onDestroy() {
		stop();
	}
}
