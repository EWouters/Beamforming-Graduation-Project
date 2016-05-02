import java.io.*;
import java.net.*;
import java.util.List;
import java.util.ArrayList;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.nio.charset.Charset;
import java.util.Iterator;
import java.util.Set;
import java.util.HashSet;
import java.util.EventListener;
import java.util.EventObject;

public class SITM
{
	// MATLAB interface stuff
	private Set<SITMListener> listeners;

	public synchronized void addSITMListener(SITMListener listener) {
		this.listeners.add(listener);
	}

	public synchronized void removeSITMListener(SITMListener listener) {
		this.listeners.remove(listener);
	}

	// List of events:
	public class OrientationEvent extends java.util.EventObject {
		private static final long serialVersionUID = 1L;
		public String phoneID;
		public float azimuth, pitch, roll;
		public byte moving_flag;

		public OrientationEvent(Object obj, String phoneID, float azimuth, float pitch, float roll, byte moving_flag) {
			super(obj);
			this.phoneID = phoneID;
			this.azimuth = azimuth;
			this.pitch = pitch;
			this.roll = roll;
			this.moving_flag = moving_flag;
		}
	}

	public class SampleEvent extends java.util.EventObject {
		private static final long serialVersionUID = 1L;
		public String phoneID;
		public short[] samples;

		public SampleEvent(Object obj, String phoneID, short[] samples) {
			super(obj);
			this.phoneID = phoneID;
			this.samples = samples;
		}
	}

	public class NewConnectionEvent extends java.util.EventObject {
		private static final long serialVersionUID = 1L;
		public String phoneID;

		public NewConnectionEvent(Object obj, String phoneID) {
			super(obj);
			this.phoneID = phoneID;
		}
	}

	public class ConnectionLostEvent extends java.util.EventObject {
		private static final long serialVersionUID = 1L;
		public String phoneID;

		public ConnectionLostEvent(Object obj, String phoneID) {
			super(obj);
			this.phoneID = phoneID;
		}
	}

	// The listener interface for MATLAB to hook into
	public interface SITMListener extends EventListener {
		void newConnection(NewConnectionEvent event);
		void connectionLost(ConnectionLostEvent event);
		void orientationUpdate(OrientationEvent event);
		void newSamples(SampleEvent event);
	}

	public synchronized void notifyNewConnection(String phoneID) {
		for(SITMListener l : listeners) {
			l.newConnection(new NewConnectionEvent(this, phoneID));
		}
	}

	public synchronized void notifyConnectionLost(String phoneID) {
		for(SITMListener l : listeners) {
			l.connectionLost(new ConnectionLostEvent(this, phoneID));
		}
	}

	public synchronized void notifyOrientation(String phoneID, float azimuth, float pitch, float roll, byte moving_flag) {
		for(SITMListener l : listeners) {
			l.orientationUpdate(new OrientationEvent(this, phoneID, azimuth, pitch, roll, moving_flag));
		}
	}

	public synchronized void notifyNewSamples(String phoneID, short[] samples) {
		for(SITMListener l : listeners) {
			l.newSamples(new SampleEvent(this, phoneID, samples));
		}
	}


	//---------------------------------------------------------------------
	// Description : Create an OutputSocket on the specified port
	//---------------------------------------------------------------------
	public SITM(int port, int sample_rate, int block_size, boolean streamStereo) throws IOException
	{
		this.sample_rate = sample_rate;
		this.block_size = block_size;
		this.stream_stereo = (streamStereo) ? (byte) 1 : (byte) 0;
		client_channel_list = new ArrayList<clientProperties>();
		listeners = new HashSet<SITMListener>();	// set of all MATLAB callback listeners
		try
		{
			// Create the ServerSocket
			m_server_channel = ServerSocketChannel.open();
			m_server_channel.bind(new InetSocketAddress(LOCALHOST, port));
			m_server_channel.configureBlocking(false);

			// Create the listening thread and listen for connections
			m_listening_thread = new ListeningThread(this, m_server_channel, client_channel_list);
			m_thread           = new Thread(m_listening_thread);
			m_thread.start();
		}
		catch (IOException e)
		{
			System.out.println("Could not listen on port " + port);
			throw(e);
		}
	}

	//---------------------------------------------------------------------
	// Description : Cleanup on destruction
	//---------------------------------------------------------------------
	protected void finalize() throws Throwable
	{
		// close any existing connections
		this.close();
		super.finalize();
	}

	//---------------------------------------------------------------------
	// Description : Close the OutputSocket. This closes all client
	//               connections and stops listening for new connections.
	//---------------------------------------------------------------------
	public void close() throws IOException
	{
		// stop the listening thread
		m_listening_thread.stop();

		// close off all sockets
		for (int i_client = 0; i_client < client_channel_list.size(); i_client++)
		{
			client_channel_list.get(i_client).closeClient();
		}
		client_channel_list.clear();

		// Close the server socket
		m_server_channel.close();
	}

	public int getNumberOfClients(){
	return client_channel_list.size();}

	public String[] getPhoneIDs()
	{
		String[] list_phone_id = new String[getNumberOfClients()];
		for (int i=0;i<getNumberOfClients();i++)
		{
			list_phone_id[i] = client_channel_list.get(i).getID();
		}
		return list_phone_id;
	}
	public String[] getStreamingIDs()
	{
		String[] list_phone_id = new String[getNumberOfClients()];
		for (int i=0;i<getNumberOfClients();i++)
		{
			if (client_channel_list.get(i).isStreaming())
		{list_phone_id[i] = client_channel_list.get(i).getID();}
		}
		return list_phone_id;
	} 
	public boolean startStreaming(String client_id, byte src)
	{
		ByteBuffer buffer;
		buffer = ByteBuffer.allocate(3);
		buffer.put(PacketType.START_STREAMING.toByte());
		buffer.put(src);
		buffer.flip();
		clientProperties client = this.getInstanceByID(client_id);
		try
		{
			client.getSocket().write(buffer);
			return true;
		}
		catch (IOException e) // writing failed
		{
			return false;
		}
	}

	public boolean stopStreaming(String client_id)
	{
		ByteBuffer buffer;
		buffer = ByteBuffer.allocate(1);
		buffer.put(PacketType.STOP_STREAMING.toByte());
		buffer.flip();
		clientProperties client = this.getInstanceByID(client_id);
		try
		{
			client.getSocket().write(buffer);
			return true;
		}
		catch (IOException e) // writing failed
		{
			return false;
		}
	}

	public clientProperties getInstanceByID(String id)
	{
		for (int i=0;i<client_channel_list.size();i++)
		{
			if (id.equals(client_channel_list.get(i).getID()))
			{return client_channel_list.get(i);}
		}
		return null;
	}

	public void setStereo(boolean streamStereo)
	{
		this.stream_stereo = streamStereo ? (byte) 1 : (byte) 0;}
	public byte getStereo()
	{return stream_stereo;}

	public static final String LOCALHOST = "0.0.0.0";

	private Thread              		m_thread;
	private ListeningThread 			m_listening_thread;
	private ArrayList<clientProperties>	client_channel_list;
	private ServerSocketChannel 		m_server_channel;
	public int							sample_rate;
	public int 							block_size;
	private byte						stream_stereo;
}

//-------------------------------------------------------------------------
// Description : Helper class that listens for new TCP/IP client
//               connections on a ServerSocket
//-------------------------------------------------------------------------
class ListeningThread implements Runnable
{
	//---------------------------------------------------------------------
	// Parameters   : server_socket          - ServerSocket to listen on
	//                connection_list        - List of connected client
	//                                         Sockets
	//                connection_stream_list - List of connected client
	//                                         DataOutputStreams
	//---------------------------------------------------------------------
	public ListeningThread(SITM sitm, ServerSocketChannel server_channel, ArrayList<clientProperties> client_channels)
	{
		this.sitm					  = sitm;
		this.m_running                = false;
		this.m_server_channel         = server_channel;
		this.m_client_channels        = client_channels;
	}

	//---------------------------------------------------------------------
	// Description : Called on Thread.start()
	//---------------------------------------------------------------------
	public void run()
	{
		// Loop listening for connections and appending them to the list
		m_running = true;

		// create selector
		try {
			selector  = Selector.open();
			// register "is acceptable" event to serversocket channel
			SelectionKey socketServerSelectionKey = m_server_channel.register(selector, SelectionKey.OP_ACCEPT);
			} catch (IOException e) {
			return;
		}
		while (m_running)
		{
			try
			{
				// if theres no data to read, keep on trying until there is.
				if (selector.select()==0)
				{
				continue;}

				// if there IS data to read, get the corresponding key(s)
				Set<SelectionKey> selectedKeys = selector.selectedKeys();
				Iterator<SelectionKey> iterator = selectedKeys.iterator();
				while(iterator.hasNext())
				{
					SelectionKey key = iterator.next();
					if (key.isAcceptable())
					{
						// accept connection, this is a new inbound connection
						SocketChannel client = m_server_channel.accept();
						if (client != null) {
							client.configureBlocking(false);
							// set the client connection to be non blocking
							// new object clientProperties
							clientProperties new_client = new clientProperties(sitm, client, key, sitm.block_size);
							SelectionKey clientKey = client.register(selector, SelectionKey.OP_READ);
							// attach object to a key, handy for finding it later
							clientKey.attach(new_client);
							m_client_channels.add(new_client);
							new_client.sendSetupPacket(sitm.sample_rate, sitm.block_size, sitm.getStereo());
						}
					}
					else if (key.isReadable())
					{
						// find the object based on the attachment to a key
						clientProperties readableClient=(clientProperties) key.attachment();
						switch (readableClient.getClientBufferState())
						{
							case IDLE:
							boolean success = readableClient.determinePacketType();
							if (success)
							{
								boolean doneReading = readableClient.continueReading();
							}
							else
							{
								// if the read wasn't successful, close the client connection.
								sitm.notifyConnectionLost(readableClient.getID());
								key.cancel();
								readableClient.closeClient();
								// remove clientChannel from the central list.
								m_client_channels.remove(readableClient);
							}
							break;

							case RECEIVINGDATA:
							boolean doneReading = readableClient.continueReading();
							break;
						}
					}
					else if (!key.isValid())
					{
						clientProperties closeableClient=(clientProperties) key.attachment();
						// connection closed by phone (probably)
						closeableClient.closeClient();
						m_client_channels.remove(closeableClient);
					}

					else
					{
						System.out.println("Key not readable");
					}
					iterator.remove();
				}

			}
			catch (IOException e)
			{
				// do nothing
			}
		}
	}

	//---------------------------------------------------------------------
	// Description : Stop the thread
	//---------------------------------------------------------------------
	public void stop() throws IOException
	{
		m_running = false;
		selector.close();
	}

	private SITM						sitm;
	private boolean      				m_running;
	private Selector 					selector;
	private ServerSocketChannel 		m_server_channel;
	private ArrayList<clientProperties>	m_client_channels;
}

class clientProperties
{
	public clientProperties(SITM parent, SocketChannel new_socket, SelectionKey new_key, int block_size)
	{
		this.parent			= parent;
		this.client_socket 	= new_socket;
		this.client_id 		= null;
		this.client_key 	= new_key;
		this.client_state	= State.CONFIGURING;
		this.block_size 	= block_size;
	}

	public void closeClient()
	{
		try
		{
			client_socket.close();
		}
		catch (IOException e)
		{}
	}

	public void setID(String client_id)
	{
		this.client_id = client_id;
	}

	public String getID()
	{
		return this.client_id;
	}

	public SocketChannel getSocket()
	{
		return client_socket;
	}

	public SelectionKey getKey()
	{
		return client_key;
	}

	public boolean isStreaming()
	{
		if (this.client_state.equals(State.STREAMING))
		{
			return true;
		}
		return false;
	}
	
	public boolean determinePacketType() throws IOException{
		// load first byte into client_buffer to determine the packet type
		this.client_buffer = ByteBuffer.allocate(1);
		int bytesRead = this.getSocket().read(client_buffer);
		if (bytesRead == 1)
		{
			this.client_packet_type = PacketType.fromByte(client_buffer.get(0));
			this.client_buffer_state = ClientBufferState.RECEIVINGDATA;
			this.client_buffer.clear();
			// allocate space depending on packet type
			switch (this.client_packet_type)
			{
				case INVALID:
				// should not occur
				System.out.println("Error while reading packet: Type is INVALID");
				break;

				case SETUP:
				// should not occur
				break;

				case ACK_SETUP:
				this.client_buffer = ByteBuffer.allocate(4); // 4 bytes to contain length of HW address
				while(this.client_buffer.hasRemaining())
				{bytesRead = this.getSocket().read(this.client_buffer);}
				this.client_buffer.flip();
				this.client_buffer = ByteBuffer.allocate(this.client_buffer.getInt(0)); // allocate space for the HW address
				break;

				case START_STREAMING:
				// should not occur
				break;

				case STOP_STREAMING:
				// should not occur
				break;

				case ACK_STOP:
				// nothing to be done here
				break;

				case STREAM_DATA:
					this.client_buffer = ByteBuffer.allocate(2*block_size); // 16 bit words
				break;

				case ORIENTATION_UPDATE:
				this.client_buffer = ByteBuffer.allocate(13); // 3x4 bytes for floats, 1 byte for flag
				break;
			}
		return true;}
		else{
		return false;}
	}


	public boolean continueReading() throws IOException { // returns true if reading is done
		int bytesRead;
		switch (this.client_packet_type)
		{
			case INVALID:
			// should not occur, obviously
			System.out.println("INVALID packet detected");
			return true;

			case SETUP:
			System.out.println("Unexpected SETUP packet detected.");
			// should not occur
			break;

			case ACK_SETUP:
			bytesRead = this.getSocket().read(this.client_buffer);
			if (this.client_buffer.remaining()!=0)
			{ // if the HW address cannot be read in one go, put in ReceivingData state and continue to other clients
				this.client_buffer_state = ClientBufferState.RECEIVINGDATA;
				return false;
			}
			else
			{
				this.client_buffer.flip();
				this.client_buffer_state = ClientBufferState.IDLE;
				this.client_id = this.client_buffer.asCharBuffer().toString();
				this.client_buffer.clear();
				parent.notifyNewConnection(this.client_id);
				return true;
			}
			case START_STREAMING:
			// shouldnt occur
			System.out.println("Unexpected START_STREAMING packet detected.");
			break;

			case STOP_STREAMING:
			System.out.println("Unexpected STOP_STREAMING packet detected.");
			break;

			case ACK_STOP:
			// client has acknowledged that he stopped streaming.
			// change client_state to idle
			this.client_state = State.IDLE;
			this.client_buffer_state = ClientBufferState.IDLE;
			return true;

			case STREAM_DATA:
				this.client_state = State.STREAMING;
				bytesRead = this.getSocket().read(this.client_buffer);
				if (this.client_buffer.remaining()!=0)
				{ // if not all audio data has been read, put in RECEIVINGDATA state.
					this.client_buffer_state = ClientBufferState.RECEIVINGDATA;
					return false;
				}
				else
				{
					// client is done receiving all audio data
					this.client_buffer.flip();
					this.client_buffer_state = ClientBufferState.IDLE;
					short[] audio_data = new short[block_size];
					client_buffer.order(ByteOrder.LITTLE_ENDIAN);
					for (int i=0;i<block_size;i++)
					{audio_data[i]=client_buffer.getShort();}
					client_buffer.order(ByteOrder.BIG_ENDIAN);
					this.client_buffer.clear();
					parent.notifyNewSamples(this.client_id, audio_data);
					// TODO: callback from MATLAB
					return true;
				}

			case ORIENTATION_UPDATE:
			bytesRead = this.getSocket().read(this.client_buffer);
			if (this.client_buffer.remaining()!=0)
			{ // if not all 9 bytes are read yet, put this client in ReceivingData state and continue to other clients
				this.client_buffer_state = ClientBufferState.RECEIVINGDATA;
				return false;
			}
			else
			{
				// client is done receiving all 9 bytes, put in idle mode
				this.client_buffer.flip();
				this.client_buffer_state = ClientBufferState.IDLE;
				float azimuth = this.client_buffer.getFloat(0);
				float pitch = this.client_buffer.getFloat(4);
				float roll = this.client_buffer.getFloat(8);
				byte moving_flag = this.client_buffer.get(12);
				this.client_buffer.clear();
				parent.notifyOrientation(client_id, azimuth, pitch, roll, moving_flag);
				return true;
			}
		}
		// if this method has not returned yet, something is wrong
		return false;
	}

	public ClientBufferState getClientBufferState(){
	return this.client_buffer_state;}

	public boolean sendSetupPacket(int sample_rate, int block_size, byte streamStereo)
	{
		this.block_size = block_size;
		ByteBuffer buffer;
		buffer = ByteBuffer.allocate(10);
		buffer.put(PacketType.SETUP.toByte());
		buffer.putInt(sample_rate);
		buffer.putInt(block_size);
		buffer.put(streamStereo);
		buffer.flip();
		try
		{
			this.getSocket().write(buffer);
			return true;
		}
		catch (IOException e) // writing failed
		{
			System.out.println("Writing SETUP packet failed");
			return false;
		}
	}

	private SITM parent;
	private SocketChannel 		client_socket;
	private String				client_id;
	private SelectionKey		client_key;
	private State				client_state;
	private ByteBuffer			client_buffer;
	private ClientBufferState	client_buffer_state = ClientBufferState.IDLE; // how far along the current packet is the client
	private PacketType 			client_packet_type; // the type of packet the client is currently receiving
	private int 				block_size;
}
