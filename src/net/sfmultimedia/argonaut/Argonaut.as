package net.sfmultimedia.argonaut 
{
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
	 * 			Argonaut.registerClassAlias("fully.qualified.RemoteClassName", LocalClass);
	 * 		</code>
	 * 	
	 * 	<li>Then, with JSON in hand:</li>
	 * 		<code>
	 * 			<p>//The json can be either a JSON-encoded String, or the object put through AS's JSON.parse() </p>
	 * 			<p>var myInstance:LocalClass = Argonaut.generate(json);</p>
	 * 		</code>
	 *  
	 * </ul>
	 * 
	 * <p>IF YOU CAN'T REQUEST CHANGES TO THE JSON STRUCTURE:</p>
	 * <p>Obviously there are times when you're simply a consumer of a service and can't force a mapping identifier. In this
	 * case, you'll need to tell Argonaut what class you want every time you hand it some JSON. This is very simple:</p>
	 * 		<code>
	 * 			<p>//The json can be either a JSON-encoded String, or the object put through AS's JSON.parse()</p>
	 * 			<p>var myInstance:LocalClass = Argonaut.generateAs(json, LocalClass);</p>
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
	 * 		<p>var jsonAsString:String = Argonaut.stringify(myInstance);</p>
	 * 	</code>
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
	public class Argonaut
	{

		/**
		 * Details of how Argonaut behaves. Use setConfiguration() to change these behaviors
		 */
		private static var config:ArgonautConfig = new ArgonautConfig();
		
		/**
		 * Override default configuration
		 * 
		 * @param value A changed configuration
		 * 
		 * @see net.sfmultimedia.argonaut.ArgonautConfig
		 */
		public static function setConfiguration(value:ArgonautConfig):void
		{
			config = value;
		}
		
		/**
		 * Get the configuration
		 */
		public static function getConfiguration():ArgonautConfig
		{
			return config;
		}
		
		/**
		 * Map the remote classname to a local class.
		 * 
		 * @param aliasName 	The alias to use, probably the fully-qualified class name of the remote class.
		 * @param classObject	The Actionscript class to which we map the alias
		 */
		public static function registerClassAlias(aliasName:String, classObject:Class):void
		{
			ClassRegister.registerClassAlias(aliasName, classObject);
		}
		
		/**
		 * Generate a Class instance from JSON.
		 * 
		 * This method works ONLY with participating services or primitives.
		 * 
		 * @param json	Either an object decoded by JSON.parse() into an object or a JSON-encoded String
		 * 
		 * @return Whatever gets generated through the deserialization process
		 */
		public static function generate(json:*):*
		{
			if (json is String)
			{
				json = JSON.parse(json);
			}
			
			return JSONDecoder.generate(json);
		}
		
		/**
		 * Convert the provided JSON to the provided AS class
		 * 
		 * Useful when leveraging JSON data where you can't have access to auto-mapping.
		 * 
		 * @param json			Either an object decoded by JSON.parse() into an object or a JSON-encoded String
		 * @param classObject	The Class we want to map the JSON to.
		 * 
		 * @return An instance, dictated by the data and the classObject
		 */
		public static function generateAs(json:*, classObject:Class):*
		{
			if (json is String)
			{
				json = JSON.parse(json);
			}
			
			return JSONDecoder.generateAs(json, classObject);
		}
		
		/**
		 * Serialize the class's public instance properties into JSON
		 * 
		 * @param instance	The instance we want to process
		 * 
		 * @return The instance expressed as a JSON string
		 */
		public static function stringify(instance:*):String
		{
			return JSONEncoder.stringify(instance);
		}
	}
}
