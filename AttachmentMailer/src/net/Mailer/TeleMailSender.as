package net.Mailer
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	
	import net.Mailer.MailInfo;
	import net.Mailer.ServerInfo;
	import net.Sockets.TeleStringSocket;

	public class TeleMailSender extends EventDispatcher
	{		
		
		private var _tSock:TeleStringSocket;
		private var commands:Array;
		private var command:int;
		
		
		public function TeleMailSender()
		{
			super();
		}
		
		
		public function SendMail( SI:ServerInfo , MI:MailInfo ):void
		{
						
			commands = 
			[	["" , "220" ] ,
				["EHLO " + SI.ServerAddress , "250" ] ,
				["AUTH LOGIN" , "334" ] ,
				[ SI.UserName , "334" ] ,
				[ SI.Password , "235"] ,
				["MAIL FROM: " + MI.FromAddress , "250"] ,
				["RCPT TO: " + MI.ToAddress, "250"] ,
				["DATA" , "354"] ,
				[ MI.transmission , "250"] ,
				[ "QUIT", "221"  ] ];
			
			command = new int (0) ;
			
			_tSock = new TeleStringSocket();			
			_tSock.addEventListener( Event.CANCEL , FatalError );	
			_tSock.addEventListener( Event.CHANGE , Responce );
			_tSock.Connect( SI.ServerAddress , SI.Port );

		}
		
		
		private function Responce ( _e:Event ):void
		{
			
			this.dispatchEvent( new ProgressEvent( ProgressEvent.PROGRESS , false , false , command , commands.length ) );
			
			trace( "Server Responce" );			
			var sr:String = _tSock.CommandLine;			
			trace( sr );			
			if ( (sr.substr(0,3) == commands[command][1]) )
			{
				command++;
				if ( command < commands.length )
				{	
					var toSend:String = commands[command][0];
					trace( toSend );
					_tSock.writeString( toSend );
				}
				else
				{
					mailSent ( );
				}
			}
			else 
			{
				trace( "unexpected responce" );
				trace( "Action Not Taken" );
				mailNotSent();
			}
			
		}		
		
		
		private function mailSent ():void
		{
			trace( "mail success" );
			dispatchEvent( new Event( Event.COMPLETE ) );
			end();
		}		
		
		
		private function mailNotSent ( ):void
		{
			trace( "mail not sent" );
			_tSock.writeString( "QUIT" );
			dispatchEvent( new Event( Event.CANCEL ) );
			end();
		}		
		
		
		private function FatalError( _e:Event ):void
		{
			trace( "fatal error" );
			dispatchEvent( _e );
			end();
		}
		
		
		private function end():void
		{			
			_tSock.removeEventListener( Event.CHANGE , Responce );
			_tSock.removeEventListener( Event.CANCEL , FatalError );
			_tSock = null;
			commands = null;
		}
		
		
	}

	
}