package com.googleproject.basicplayerrecorder;

//import java.util.ArrayList;
//import java.util.List;
import java.util.Date;
import java.util.Locale;
import java.text.SimpleDateFormat;

import android.app.Activity;

import android.os.Bundle;
import android.os.Environment;
import android.os.SystemClock;

import android.widget.Spinner;
import android.widget.ToggleButton;
//import android.widget.ArrayAdapter;
import android.widget.Toast;
import android.widget.Chronometer;


import android.view.View;
//import android.view.View.OnClickListener;

import android.util.Log;
 


public class PlayerRecord extends Activity  
{
	private Chronometer chronometer;
	private Spinner spinner_fs;
	private Spinner spinner_audio_input;
	private Spinner spinner_channel_config;

	
	private static final String LOG_TAG = "BasicPayerRecord";
    private static String mFileName = null;

	private ExtAudioRecorder recorder = null;
   
	private ExtAudioRecorder.State state;
	
	//private SshConnect sshS =null;
	
	private boolean isRecording = false;
	
	private String datef;
	
	private SimpleDateFormat sdf;
	
	private int recordingFS=0;
	
	private void startRecording(int recFS,String audio_input,String channel_config)
	{
		isRecording = false;
		recordingFS=0;
		mFileName = Environment.getExternalStorageDirectory().getAbsolutePath();
//		mFileName += "/audiorecordtest.wav";
		mFileName += "/NX504_";
		datef = "yyyyMMdd_HHmmss";
		sdf = new SimpleDateFormat(datef,Locale.US);
		mFileName += String.format("%s",sdf.format(new Date()));
		mFileName = mFileName += ".wav";

		//recorder = new ExtAudioRecorder(ExtAudioRecorder.RECORDING_UNCOMPRESSED,RECORDER_MIC,RECORDER_SAMPLERATE,RECORDER_CHANNELS,RECORDER_AUDIO_ENCODING);
	    //state = recorder.getState();
	    recorder = ExtAudioRecorder.getInstance(false,recFS,audio_input,channel_config);
    	state = recorder.getState();
   
	    if (state == ExtAudioRecorder.State.INITIALIZING)
	    {
	    	recorder.setOutputFile(mFileName);
	    	
	    	if (state != ExtAudioRecorder.State.ERROR)
		    {
		    	recorder.prepare();
		    	state = recorder.getState();
		    	if (state != ExtAudioRecorder.State.ERROR)
			    {
			    	recorder.start();
			    	state = recorder.getState();
			    	if (state == ExtAudioRecorder.State.RECORDING)
				    {
			    		recordingFS = recorder.getRecFs();
			    		chronometer.setBase(SystemClock.elapsedRealtime());
			    		chronometer.start();
			    		Log.e(LOG_TAG, "Recording is on!");
			    		Log.e(LOG_TAG,mFileName);
			    		Toast.makeText(PlayerRecord.this,"Recording is started!" + "\n Sampling Frequency (Hz): "+ String.valueOf(recordingFS) + "\n Audio Input: " + String.valueOf(spinner_audio_input.getSelectedItem()) + "\n Channel Config: " + String.valueOf(spinner_channel_config.getSelectedItem()),Toast.LENGTH_SHORT).show();
			    		isRecording = true;
				    }
			    	else
			    	{
		    			Log.e(LOG_TAG, "An error ocurred while starting the recorder");
			    	}
			    	
			    }
			    else
			    {
			    	  Log.e(LOG_TAG, "An error ocurred while trying to prepare for recording");
			    }

		    }
		    else
		    {
		    	  Log.e(LOG_TAG, "An error ocurred while trying to setup the filename");
		    }
		    
	    }
	    else
	    {
	    	  Log.e(LOG_TAG, "The recorder did not initialized!");
	    }
	    
	    
	}
	
    //convert short to byte
	
	private void stopRecording()
	{
	    // stops the recording activity
		recordingFS=0;
		state = recorder.getState();
	    if ( recorder != null && state == ExtAudioRecorder.State.RECORDING  && isRecording)
	    {
	    	recorder.release();
	    	chronometer.stop();
	    	state = recorder.getState();
	    	if ( state != ExtAudioRecorder.State.ERROR)
	    	{
	    		isRecording = false;
	    		Toast.makeText(PlayerRecord.this,"Recording is stopped",Toast.LENGTH_SHORT).show();
	    	}
	    	else
		    {
		    	  Log.e(LOG_TAG, "Tried to stop recording but an error occured.");
		    	  Toast.makeText(PlayerRecord.this,"Tried to stop recording but an error occured.",Toast.LENGTH_SHORT).show();
		    }
	    }
	    else
	    {
	    	  Log.e(LOG_TAG, "Tried to stop recording but recording is not on!");
	    	  Toast.makeText(PlayerRecord.this,"Tried to stop recording but recording is not on!",Toast.LENGTH_SHORT).show();
	    }
	}
	
	
    @Override
    protected void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_player_record);
        spinner_fs = (Spinner) findViewById(R.id.spinner_fs);
        spinner_audio_input = (Spinner) findViewById(R.id.spinner_audio_input);
        spinner_channel_config = (Spinner) findViewById(R.id.spinner_channel_config);
        chronometer = (Chronometer) findViewById(R.id.chronometer);
//        sshS = new SshConnect(); 
    }

    public void onToggleClicked( View v )
    {
    	
    	
    	boolean on = ((ToggleButton) v).isChecked();
        
        if(on)
        {
        	startRecording(Integer.parseInt(String.valueOf(spinner_fs.getSelectedItem())),String.valueOf(spinner_audio_input.getSelectedItem()),String.valueOf(spinner_channel_config.getSelectedItem()));
        	if( recorder == null || state != ExtAudioRecorder.State.RECORDING  || !(isRecording))
        	{
        		Toast.makeText(PlayerRecord.this,"The recorder could not be started!",Toast.LENGTH_SHORT).show();
        		((ToggleButton) v).setChecked(false);
        		chronometer.setBase(SystemClock.elapsedRealtime());
        	}
//        	sshS.InitConnection();
        }
        else
        {
        	stopRecording();
        }
    }


    
}
