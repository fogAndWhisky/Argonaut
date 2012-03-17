package net.sfmultimedia.argonaut
{
	/**
	 * Refer all errors to this class. We can either throw the error, simply trace it, or ignore it altogether 
	 * 
	 * @author mtanenbaum
	 */
	public class ErrorHandler
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
					trace(event.error.message);
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
