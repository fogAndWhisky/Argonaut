package net.sfmultimedia.argonaut
{
	import flash.events.EventDispatcher;
	/**
	 * Refer all errors to this class. We can either throw the error, simply trace it, or ignore it altogether 
	 * 
	 * @author mtanenbaum
	 */
	public class ErrorHandler extends EventDispatcher
	{
		public var _config:ArgonautConfig;
		
		/**
		 * Class constructor
		 */
		public function ErrorHandler(config:ArgonautConfig) 
		{
			this.config = config;
		}

		/**
		 * Handle decoding errors
		 * 
		 * @throws ArgonautErrorEvent.DECODING_ERROR
		 * @throws ArgonautErrorEvent.ENCODING_ERROR
		 * @throws ArgonautErrorEvent.REGISTER_ERROR
		 * 
		 * @param event An ArgonautErrorEvent, with error as its payload
		 */
		public function handleError(event:ArgonautErrorEvent):void
		{
			var decodeErrorHandleMode:String = config.decodeErrorHandleMode;
			switch(decodeErrorHandleMode)
			{
				case ArgonautConstants.DECODE_ERROR_IGNORE:
					return;
				case ArgonautConstants.DECODE_ERROR_TRACE:
					trace("ARGONAUT::", event.type, event.error.message);
					dispatchEvent(event);
					return;
				case ArgonautConstants.DECODE_ERROR_ERROR:
					throw (event.error);
			}
		}

		public function get config():ArgonautConfig
		{
			return _config;
		}

		public function set config(value:ArgonautConfig):void
		{
			_config = value;
		}
	}
}
