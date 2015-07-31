package net.Sockets
{	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	public class TeleStringSocket extends EventDispatcher
	{		
		private const CR:int = 13; // Carriage Return (CR)
		private const WILL:int = 0xFB; // 251 - WILL (option code)
		private const WONT:int = 0xFC; // 252 - WON'T (option code)
		private const DO:int   = 0xFD; // 253 - DO (option code)
		private const DONT:int = 0xFE; // 254 - DON'T (option code)
		private const IAC:int  = 0xFF; // 255 - Interpret as Command (IAC)
	
		private var state:int = 0;
		private var _timeOUT:Timer;
		
		private var _SocketConnection:Socket;
		private var _ReadBuffer:String;	
		
		public function TeleStringSocket()
		{
			super();
			_timeOUT = new Timer( 1024 , 1);
			_timeOUT.addEventListener( TimerEvent.TIMER_COMPLETE , sendBuffer );
			
			_SocketConnection = new Socket();
			_ReadBuffer = new String();
		}		
		
		public function Connect( Host:String , Port ):void
		{			
			_SocketConnection.addEventListener( Event.CONNECT , onConnect );
			_SocketConnection.addEventListener( Event.CLOSE, onClose );
			_SocketConnection.addEventListener( IOErrorEvent.IO_ERROR , onIOerr );
			_SocketConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR , onSecurityErr );
			_SocketConnection.addEventListener( ProgressEvent.SOCKET_DATA , dataHandler );

			_SocketConnection.connect( Host , Port );			
		}
				
		// notifies of successful connection
		private function onConnect( _e:Event ):void
		{
			trace( "Connection Successful" );
			_SocketConnection.removeEventListener( Event.CONNECT , onConnect );
		}
				
		/**
		 * This method is called by our application and is used to send data
		 * to the server.
		 */
		public function writeString(s:String):void
		{
			_SocketConnection.writeUTFBytes( s + "\r\n" );
			_SocketConnection.flush();
		}	
		
		public function writeByteArray( b:ByteArray):void
		{
			_SocketConnection.writeBytes( b );
			_SocketConnection.flush();
		}
			
		/**
		 * This method is called when the socket receives data from the server.
		 */
		private function dataHandler( _pe:ProgressEvent):void
		{
			var n:int = _SocketConnection.bytesAvailable;
			// Loop through each available byte returned from the socket connection.
			while (--n >= 0) {
				// Read next available byte.
				var b:int = _SocketConnection.readUnsignedByte();
				switch (state) {
					case 0:
						// If the current byte is the "Interpret as Command" code, set the state to 1.
						if (b == IAC) {
							state = 1;
							// Else, if the byte is not a carriage return, display the character using the msg() method.
						} else if (b != CR) {
							msg(String.fromCharCode(b));
						}
						break;
					case 1:
						// If the current byte is the "DO" code, set the state to 2.
						if (b == DO) {
							state = 2;
						} else {
							state = 0;
						}
						break;
					// Blindly reject the option.
					case 2:
						/*
						Write the "Interpret as Command" code, "WONT" code, 
						and current byte to the socket and send the contents 
						to the server by calling the flush() method.
						*/
						_SocketConnection.writeByte(IAC);
						_SocketConnection.writeByte(WONT);
						_SocketConnection.writeByte(b);
						_SocketConnection.flush();
						state = 0;
						break;
				}
			}
		}	
				
		// sercurity error handler
		private function onSecurityErr(_see:SecurityErrorEvent):void
		{
			trace( "Security Error: " + _see.errorID );
			dispatchEvent( new Event( Event.CANCEL ) );
			_SocketConnection.close();			
		}
		
		// io error handler 
		private function onIOerr(_e:IOErrorEvent):void
		{
			trace( "IO Error: " + _e.errorID );
			dispatchEvent( new Event( Event.CANCEL ) );
			_SocketConnection.close();
		}
			
		private function onClose(_e:Event):void
		{
			trace( "Closing Connection..." );			

			_SocketConnection.addEventListener( Event.CONNECT , onConnect );
			_SocketConnection.addEventListener( Event.CLOSE, onClose );
			_SocketConnection.addEventListener( IOErrorEvent.IO_ERROR , onIOerr );
			_SocketConnection.addEventListener( SecurityErrorEvent.SECURITY_ERROR , onSecurityErr );
			_SocketConnection.addEventListener( ProgressEvent.SOCKET_DATA , dataHandler );		
		}	
		
		// adds to buffer on new input , if no new input for a while send the buffer
		private function msg(value:String):void
		{
			_ReadBuffer += value;
			_timeOUT.reset();
			_timeOUT.start();
		}
				
		private function sendBuffer( _te:TimerEvent ):void
		{
			trace( "buffer change" );
			dispatchEvent( new Event( Event.CHANGE ) );
		}
				
		public function get CommandLine( ):String
		{
			var serverResponce:String = new String( _ReadBuffer );
			_ReadBuffer = new String();
			return serverResponce;
		}
		
	}

}