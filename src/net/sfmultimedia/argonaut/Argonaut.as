package net.sfmultimedia.argonaut 
{
	import flash.events.EventDispatcher;
	/**
	 * <p>Argonaut provides AMF-style class serialization/deserialization between AS3 and JSON objects. It leverages
	 * the built-in JSON class in Flex SDK 4.6. If your project requires an older SDK, see the companion
	 * project argonaut_non-native-.01.</p>
	 * 
	 * <p>Use it for:</p>
	 * <ul>
	 * <li>mapping JSON objects into first-class AS3 Classes</li>
	 * <li>mirroring JSON objects server-client side the same way you would with AMF through AMFPHP or Red5</li>
	 * <li>Serializing AS instances to JSON (only public, non-static properties with be serialized)</li>
	 * </ul>
	 * 
	 * <p>How to use:</p>
	 * <p>IF YOU CAN REQUEST CHANGES TO THE JSON STRUCTURE:</p>
	 * <p>This is the best method and the most akin to AMF. The JSON will be expected to provide an alias property (by default, "__jsonclass__")
	 * indicating the fully-qualified class name.</p>
	 * <ul>
	 * <li>Map the class. This is equivalent to flash.net.registerClassAlias</li>
	 * 		<code>
	 * 			var argonaut:Argonaut = new Argonaut();
	 * 			argonaut.registerClassAlias("fully.qualified.RemoteClassName", LocalClass);
	 * 		</code>
	 * 	
	 * 	<li>Then, with JSON in hand:</li>
	 * 		<code>
	 * 			<p>//The json can be either a JSON-encoded String, or the object put through AS's JSON.parse() </p>
	 * 			<p>var myInstance:LocalClass = argonaut.generate(json);</p>
	 * 		</code>
	 *  
	 * </ul>
	 * 
	 * <p>IF YOU CAN'T REQUEST CHANGES TO THE JSON STRUCTURE:</p>
	 * <p>Obviously there are times when you're simply a consumer of a service and can't force a mapping identifier. In this
	 * case, you'll need to tell Argonaut what class you want every time you hand it some JSON. This is very simple:</p>
	 * 		<code>
	 * 			<p>//The json can be either a JSON-encoded String, or the object put through AS's JSON.parse()</p>
	 * 			<p>var myInstance:LocalClass = argonaut.generateAs(json, LocalClass);</p>
	 * 		</code>
	 * 		
	 * 	<p>Serializing:</p>
	 * 	<p>To convert an instance to a JSON formatted String, call <code>Argonaut.stringify()</code>. This is identical to native <code>JSON.stringify()</code>,
	 * 	except:</p>
	 * 	<ul>
	 *  <li>AS classes may specify a <code>[DontSerialize]</code> metatag so that you can suppress certain properties.
	 *  NB: use of the [DontSerialize] metatag requires <code>-keep-as3-metadata+=“DontSerialize”</code> to be marked in the compiler.</li>
	 *  <li>Complex classes will by default by tagged with "__jsonclass__":"fully.qualified::ClassName". This tag can be
	 *  changed or suppressed altogether by changing the ArgonautConfig.</li>
	 *  </ul>
	 * 	<code>
	 * 		<p>var jsonAsString:String = argonaut.stringify(myInstance);</p>
	 * 	</code>
	 * 	
	 * 	@eventType ArgonautErrorEvent.DECODE_ERROR - Handle errors during decoding
	 * 	@eventType ArgonautErrorEvent.ENCODE_ERROR - Handle errors during encoding
	 * 	@eventType ArgonautErrorEvent.PARSE_ERROR - Handle errors during parsing
	 * 	@eventType ArgonautErrorEvent.REGISTER_ERROR - Handle errors during class registration
	 * 
	 * 
	 * @author mtanenbaum
	 * 
	 * @internal
	 * Argonaut is released under the MIT License
	 * Copyright (C) 2012, Marc Tanenbaum
	 *
	 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
	 * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
	 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
	 * Software is furnished to do so, subject to the following conditions:
	 *
	 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	 *
	 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
	 * WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
	 * OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
	 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	 */
	public class Argonaut extends EventDispatcher implements IArgonaut
	{

		/**
		 * Details of how Argonaut behaves. Use setConfiguration() to change these behaviors
		 */
		private var config:ArgonautConfig = new ArgonautConfig();
		
		/**
		 * Registry of classes we've mapped
		 */
		 private var classRegister:ClassRegister;
		
		/**
		 * The error handler
		 */
		 private var errorHandler:ErrorHandler;
		
		/**
		 * Encodes classes to JSON
		 */
		 private var encoder:JSONEncoder;
		
		/**
		 * Decodes classes from JSON
		 */
		 private var decoder:JSONDecoder;
		 
		/**
		 * Class constructor
		 */
		public function Argonaut() 
		{
			classRegister = new ClassRegister();
			errorHandler = new ErrorHandler(config);
			encoder = new JSONEncoder(config, classRegister);
			decoder = new JSONDecoder(config, classRegister);
			
			//Set up all listeners
			classRegister.addEventListener(ArgonautErrorEvent.REGISTER_ERROR, errorHandler.handleError);
			encoder.addEventListener(ArgonautErrorEvent.ENCODING_ERROR, errorHandler.handleError);
			decoder.addEventListener(ArgonautErrorEvent.DECODING_ERROR, errorHandler.handleError);
			//Then have this class listen to the central Error Bus
			errorHandler.addEventListener(ArgonautErrorEvent.REGISTER_ERROR, onErrorEvent);
			errorHandler.addEventListener(ArgonautErrorEvent.ENCODING_ERROR, onErrorEvent);
			errorHandler.addEventListener(ArgonautErrorEvent.DECODING_ERROR, onErrorEvent);
			errorHandler.addEventListener(ArgonautErrorEvent.PARSE_ERROR, onErrorEvent);
		}
		
		/**
		 * @inheritDoc
		 */
		public function setConfiguration(value:ArgonautConfig):void
		{
			config = value;
			encoder.config = config;
			decoder.config = config;
			errorHandler.config = config;
		}
		
		/**
		 * @inheritDoc
		 */
		public function getConfiguration():ArgonautConfig
		{
			return config;
		}
		
		/**
		 * @inerhitDoc
		 */
		public function registerClassAlias(aliasName:String, classObject:Class):void
		{
			classRegister.registerClassAlias(aliasName, classObject);
		}
		
		/**
		 * @inheritDoc
		 */
		public function generate(json:*):*
		{
			if (json is String)
			{
				json = processJsonString(json);
			}
			
			return decoder.generate(json);
		}
		
		/**
		 * @inheritDoc
		 */
		public function generateAs(json:*, classObject:Class):*
		{
			if (json is String)
			{
				json = processJsonString(json);
			}
			
			return decoder.generateAs(json, classObject);
		}
		
		/**
		 * @inheritDoc
		 */
		public function stringify(instance:*, pretty:Boolean = false):String
		{
			return encoder.stringify(instance, pretty);
		}
		
		/**
		 * Use native json parsing to turn the string into a JSON-legal object
		 * 
		 * @throws ArgonautErrorEvent.PARSE_ERROR if not parseable JSON
		 */
		private function processJsonString(value:String):Object
		{
			try
			{
				return JSON.parse(value);
			}
			catch(e:Error)
			{
				errorHandler.handleError(new ArgonautErrorEvent(ArgonautErrorEvent.PARSE_ERROR, e));
			}
			return null;
		}

		/**
		 * Relay to allow external listeners to react to Argonaut error handling
		 */
		private function onErrorEvent(event:ArgonautErrorEvent):void
		{
			dispatchEvent(event);
		}
	}
}
