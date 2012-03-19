package net.sfmultimedia.argonaut
{
	import org.robotlegs.mvcs.Actor;

	/**
	 * A shim for implementing argonaut in the RobotLegs context.
	 * 
	 * In your RobotLegs context, map Argonaut like this:
	 * 
	 * injector.mapSingletonOf(IArgonaut, ArgonautForRobotLegs);
	 * 
	 * @author mtanenbaum
	 */
	public class ArgonautForRobotLegs extends Actor implements IArgonaut
	{
		private var argonaut:Argonaut;
		
		/**
		 * Class constructor
		 */
		public function ArgonautForRobotLegs()
		{
			super();
			argonaut = new Argonaut();
			argonaut.addEventListener(ArgonautErrorEvent.DECODING_ERROR, onErrorEvent);
			argonaut.addEventListener(ArgonautErrorEvent.ENCODING_ERROR, onErrorEvent);
			argonaut.addEventListener(ArgonautErrorEvent.PARSE_ERROR, onErrorEvent);
			argonaut.addEventListener(ArgonautErrorEvent.REGISTER_ERROR, onErrorEvent);
		}

		/**
		 * @inheritDoc
		 */
		public function setConfiguration(value:ArgonautConfig):void
		{
			argonaut.setConfiguration(value);
		}

		/**
		 * @inheritDoc
		 */
		public function getConfiguration():ArgonautConfig
		{
			return argonaut.getConfiguration();
		}

		/**
		 * @inheritDoc
		 */
		public function registerClassAlias(aliasName:String, classObject:Class):void
		{
			argonaut.registerClassAlias(aliasName, classObject);
		}

		/**
		 * @inheritDoc
		 */
		public function generate(json:*):*
		{
			return argonaut.generate(json);
		}

		/**
		 * @inheritDoc
		 */
		public function generateAs(json:*, classObject:Class):*
		{
			return argonaut.generateAs(json, classObject);
		}

		/**
		 * @inheritDoc
		 */
		public function stringify(instance:*, pretty:Boolean = false):String
		{
			return argonaut.stringify(instance, pretty);
		}

		/**
		 * Relay to allow external listeners to react to Argonaut error handling
		 */
		private function onErrorEvent(event:ArgonautErrorEvent):void
		{
			dispatch(event);
		}
	}
}
