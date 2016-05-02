package com.googleproject.basicplayerrecorder;


import java.util.Properties;
import com.jcraft.jsch.*;


import android.os.AsyncTask;
import android.util.Log;


public class SshConnect
{
    public SshConnect()
	{
    	Log.e(SshConnect.class.getName(), "Constructed");
	}
    
    public void InitConnection()
    {
    	SshInitiateConnection SshInit = new SshInitiateConnection();
        SshInit.execute();
    }
    
	private class SshInitiateConnection extends AsyncTask <Void , Void, String>
	{
		String host="10.0.2.28";
		String user ="jmartinez";
		String pwd = "password";
		int port = 22;

	     protected String doInBackground(Void...arg0)
	     {
			Properties props = new Properties(); 
		    props.put("StrictHostKeyChecking","no");
			Properties config = new Properties();
		    config.put("StrictHostKeyChecking", "no");
		    config.put("compression.s2c", "zlib,none");
		    config.put("compression.c2s", "zlib,none");
		    try
		    {
			    JSch jsch=new JSch();  
			    Session session=jsch.getSession(user, host, port);          
			    session.setConfig(config);
			    session.setPassword(pwd);
			    session.connect();
			    Log.e(SshConnect.class.getName(), "Connected!");
		    }
		    catch (Exception e)
			{
				Log.e(SshConnect.class.getName(), "Could not initiate connection");
			}
		    
		    String text = "Connected!";
	
	         return text;
	     }
	
//	     protected void onProgressUpdate(Integer... progress)
//	     {
//	         setProgressPercent(progress[0]);
//	     }

//	     protected void onPostExecute(String... result)
//	     {
//	         showDialog(result);
//	     }


	}
}