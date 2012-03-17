package net.sfmultimedia.argonaut
{
	import flash.events.Event;

	/**
	 * Error event thrown by Argonaut classes.
	 * 
	 * Use the consts to discriminate between error types 
	 * 
	 * @author mtanenbaum
	 */
	public class ArgonautErrorEvent extends Event
	{
		public static const ENCODING_ERROR:String = "ENCODING_ERROR";
		
		public static const DECODING_ERROR:String = "DECODING_ERROR";
		
		public static const REGISTER_ERROR:String = "REGISTER_ERROR";
		
		public var error:Error;
		
		public function ArgonautErrorEvent(type:String, error:Error, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.error = error;
		}
		
		override public function clone():Event
		{
			return new ArgonautErrorEvent(type, error, bubbles, cancelable);
		}
	}
}
