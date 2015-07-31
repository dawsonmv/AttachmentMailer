package net.Mailer
{
	
	import flash.utils.ByteArray;
		
	import net.utils.Base64conversion;

	public class MailInfo
	{
		
		private const _boundary1:String = new String( "boundary1oo*+*###*^*###*$*###*^*###*+*ooboundary1");
	//	private const _boundary2:String = new String( "boundary2++^o^%%%o^o%%%^@^%%%o^o%%%^o^++boundary2");
		
		public var ToAddress:String;
		public var FromAddress:String;
		public var Subject:String;
		public var Message:String;
		private var _MIMEtype:String;
		private var _Attachment:String;
		private var _FileName:String;
	
		public function MailInfo()
		{
			ToAddress = new String();
			FromAddress = new String();
			Subject = new String();
			Message = new String();
			_MIMEtype = new String();
			_Attachment = new String();
			_FileName = new String();
		}
		
		public function  setAttachment( _a:ByteArray , _MT:String , _FN:String ):void
		{
						
			_Attachment = Base64conversion.encodeByteArray( _a );
			_MIMEtype = _MT;
			_FileName = _FN;
		
		}
		
		public function get transmission( ):String
		{
			var _transmission:ByteArray = new ByteArray();
			
			// email template
		
		//	_transmission.writeUTFBytes ( "X-Mailer: Heradlic Crest Creator\r\n" ); 
			_transmission.writeUTFBytes ( "From: <" + FromAddress + ">\r\n" );
			
			_transmission.writeUTFBytes ( "To: <" + ToAddress + ">\r\n" );
			
			_transmission.writeUTFBytes ( "Subject: " + Subject + "\r\n" );
			
			_transmission.writeUTFBytes ( "MIME-Version: 1.0\r\n" );
			
			_transmission.writeUTFBytes ( "Content-Type: multipart/mixed; boundary=" + _boundary1 + "\r\n\r\n" );
			
			_transmission.writeUTFBytes ( "--" + _boundary1 + "\r\n" );
			
		//	_transmission.writeUTFBytes ( "Content-Type: multipart/alternative; boundary=" + _boundary2 + "\r\n\r\n" );
			
		//	_transmission.writeUTFBytes ( "--" + _boundary2 + "\r\n" );				
			
			_transmission.writeUTFBytes ( "Content-Type: text/plain; charset=UTF-8\r\n" );			
			
			_transmission.writeUTFBytes ( "Content-Transfer-Encoding: quoted-printable\r\n\r\n" );

			_transmission.writeUTFBytes ( Message + "\r\n\r\n" );
			
		//	_transmission.writeUTFBytes ( "--" + _boundary2 + "\r\n" );
			
		// 	_transmission.writeUTFBytes ( "Content-Type: text/html; charset=UTF-8\r\n" );			
			
		//	_transmission.writeUTFBytes ( "Content-Transfer-Encoding: quoted-printable\r\n\r\n" );
			
		//	_transmission.writeUTFBytes ( "<html><body><div style=\"color:#000; background-color:#fff; font-family:times new roman, new york, times, serif;font-size:24pt\">" + Message + "</div></body></html>\r\n" );
			
		//	_transmission.writeUTFBytes ( "--" + _boundary2 + "--\r\n" );
			
			_transmission.writeUTFBytes ( "--" + _boundary1 + "\r\n" );
			
			_transmission.writeUTFBytes ( "Content-Type: " + _MIMEtype + "; name=\"" + _FileName + "\"\r\n" );
			
			_transmission.writeUTFBytes ( "Content-Transfer-Encoding: base64\r\n" );

			_transmission.writeUTFBytes ( "Content-Disposition: attachment; filename=\"" + _FileName + "\"\r\n\r\n" );			
			
			_transmission.writeUTFBytes ( _Attachment + "\r\n\r\n"); 
			
			_transmission.writeUTFBytes ( "--" + _boundary1 + "--\r\n");
			
			_transmission.writeUTFBytes ( "." );
			
			return _transmission.toString();
		}		
		
	}
}