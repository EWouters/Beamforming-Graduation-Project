package bep_c.measurementapp;

import android.support.v7.app.ActionBarActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class SetupActivity extends ActionBarActivity {
	private Intent mIntent;

	public static final String HOST_KEY = "host";
	public static final String PORT_KEY = "port";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_setup);

		// display phone UID
		String uid = NetworkInterfaceThread.getUID(this);
		((TextView)findViewById(R.id.uid_display)).setText(uid);

		if (savedInstanceState != null) {
			// restore settings from bundle
			((EditText)findViewById(R.id.host_field)).setText(savedInstanceState.getString(HOST_KEY));
		        ((EditText)findViewById(R.id.port_field)).setText(savedInstanceState.getString(PORT_KEY));
		} else {
			// TODO: read settings from file
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.menu_setup, menu);
		return super.onCreateOptionsMenu(menu);
	}

	public void startRecordService() {
		// get host and port from UI
		try {
			String mHost = ((EditText)findViewById(R.id.host_field)).getText().toString();
			int mPort = Integer.valueOf(((EditText)findViewById(R.id.port_field)).getText().toString());
			// create intent
			mIntent = new Intent(this, RecordService.class);
			mIntent.putExtra(HOST_KEY, mHost);
			mIntent.putExtra(PORT_KEY, mPort);

			// start service
			startService(mIntent);
		} catch (NumberFormatException e) {
			Toast.makeText(this, R.string.invalid_port, Toast.LENGTH_SHORT).show();
		}

	}

	public void stopRecordService() {
		if(mIntent == null)
			mIntent = new Intent(this, RecordService.class);
		stopService(mIntent);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();

		switch(item.getItemId()) {
			case R.id.action_start_service:
				startRecordService();
				break;

			case R.id.action_stop_service:
				stopRecordService();
				break;
		}

		return super.onOptionsItemSelected(item);
	}

	@Override
	public void onSaveInstanceState(Bundle savedInstanceState) {
		String host = ((EditText)findViewById(R.id.host_field)).getText().toString();
		String port = ((EditText)findViewById(R.id.port_field)).getText().toString();

		savedInstanceState.putString(HOST_KEY, host);
		savedInstanceState.putString(PORT_KEY, port);
	}
}
