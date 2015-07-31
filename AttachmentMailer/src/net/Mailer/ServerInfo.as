package net.Mailer
{

	import net.utils.Base64conversion;

	public class ServerInfo
	{
		public var ServerAddress:String;
		public var Port:int;
		private var _UserName:String;
		private var _Password:String;
				
		public function ServerInfo()
		{
			ServerAddress =  new String();
			Port = new int();
			_UserName = new String();
			_Password = new String();
		}
		
		public function get UserName( ) : String
		{
			return _UserName;
		}
		
		public function set UserName ( _u : String) :void
		{
			_UserName = Base64conversion.encode(_u);
		}
		
		public function get Password ( ) :String
		{
			return _Password;
		}
		
		public function set Password ( _p:String ):void
		{
			_Password = Base64conversion.encode( _p );
		}

	}
	
}