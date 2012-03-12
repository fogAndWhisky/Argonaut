package net.sfmultimedia.argonaut
{
	import flash.utils.getDefinitionByName;

	/**
	 * <p>Responsible for converting raw JSON into Classes</p>
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
	public class JSONDecoder
	{
		/** The configuration of the current Argonaut instance */
		private static var config:ArgonautConfig = new ArgonautConfig();
		
		
		/**
		 * Generate a Class instance from JSON by matching its foreign alias to a previously mapped alias.
		 * 
		 * This method works ONLY with participating services or primitives.
		 * 
		 * @param json		The json Object
		 * @param config	The configuration of the Argonaut instance we're currently using
		 * 
		 * @return Whatever gets generated through the deserialization process
		 */
		public static function generate(json:Object, config:ArgonautConfig = null):*
		{
			if (config != null)
			{
				JSONDecoder.config = config;
			}
			
			var aliasId:String = JSONDecoder.config.aliasId;

			// Handle primitives
			if (json is Array)
			{
				return parseElement([], json);
			}
			else if (json is Boolean || json is Number || json is String)
			{
				return json;
			}

			// If class not mapped, throw an error
			if (!isParticipant(json))
			{
				throw new Error("ArgonautJSONDecoder.generate only works on participating classes. The JSON provided must have an " + aliasId + " property defined. See generateAs instead.");
			}
			else if (!ClassRegister.getClassByAlias(json[aliasId]))
			{
				// The object was passed through generate, but we have no mapping.
				// We can recurse trough it and see if any properties can be mapped
				return parseElement({}, json);
			}
			else
			{
				return generateAs(json, ClassRegister.getClassByAlias(json[aliasId]));
			}
		}

		/**
		 * Generate a Class instance from JSON by providing the class to generate.
		 * 
		 * @param json			The json Object
		 * @param classObject	The class into which we wish to convert this json
		 * 
		 * @return An instantiated instance
		 */
		public static function generateAs(json:Object, classObject:Class):*
		{
			// Ensure class is registered.
			ClassRegister.registerClass(classObject);

			// Start parsing
			return parseElement(new classObject(), json);
		}

		/**
		 * Recursively parse the nodes of the json data and assign it to the return value
		 * 
		 * This method is highly armored against failure, since a lot can go wrong at this point.
		 * If the property is read-only, or a class requires constructor arguments, things can go awry.
		 * 
		 * @param retVal	The instance we're constructing
		 * @param json		The data with which we're populating the instance
		 * 
		 * @return The instance
		 */
		private static function parseElement(retv:*, json:Object):*
		{
			var classObject:Class;
			var classMap:Object;
			classObject = ClassRegister.registerClassByInstance(retv);
			classMap = ClassRegister.getClassMap(classObject);

			for (var key:String in json)
			{
				var value:Object = json[key];
				var mapping:PropertyTypeMapping = classMap[key];

				if (mapping == null)
				{
					// No mapping. Use the JSON value.
					if (value is Boolean || value is Number || value is String)
					{
						// Simple values simply get assigned
						try
						{
							setValue(retv, key, value);
						}
						catch(e:Error)
						{
							handleError(e);
						}
					}
					else if (value is Array)
					{
						// Arrays get recursively parsed
						try
						{
							retv[key] = [];
							parseElement(retv[key], value);
						}
						catch(e:Error)
						{
							handleError(e);
						}
					}
					else
					{
						// It's an object and we have no mapping
						try
						{
							retv[key] = {};
							parseElement(retv[key], value);
						}
						catch(e:Error)
						{
							handleError(e);
						}
					}
				}
				else
				{
					switch(mapping.normalizedType)
					{
						case ArgonautConstants.BOOLEAN:
						case ArgonautConstants.NUMBER:
						case ArgonautConstants.STRING:
							// Simple values simply get assigned
							try
							{
								setValue(retv, key, value);
							}
							catch(e:Error)
							{
								handleError(e);
							}
							break;
						case ArgonautConstants.ARRAY:
							// Arrays get recursively parsed
							try
							{
								retv[key] = [];
								parseElement(retv[key], value);
							}
							catch(e:Error)
							{
								handleError(e);
							}
							break;
						case ArgonautConstants.VECTOR:
							// Vectors get recursively parsed
							try
							{
								if (retv[key] == null)
								{
									handleError(new Error("WARNING: Since Adobe Player doesn't support Generics, Vectors need to have a default instantiation in the client class in order to be deserialized."));
								}

								// parseElement(retv[key], value);
								var elementType:String = (mapping.elementNormalizedType == null) ? mapping.elementType : mapping.elementNormalizedType;
								parseList(retv[key], value as Array, elementType);
							}
							catch(e:Error)
							{
								handleError(e);
							}
							break;
						case ArgonautConstants.OBJECT:
							// It's typed to Object or *
							try
							{
								retv[key] = {};
								parseElement(retv[key], value);
							}
							catch(e:Error)
							{
								handleError(e);
							}
							break;
						default:
							try
							{
								var valueClass:Object = getDefinitionByName(mapping.type) as Class;
								retv[key] = new valueClass();
								parseElement(retv[key], value);
							}
							catch(e:Error)
							{
								handleError(e);
							}
							break;
					}
				}
			}

			return retv;
		}

		/**
		 * Loop through a list, instantiating elements of dataType when provided
		 */
		private static function parseList(retv:*, json:Array, dataType:String = null):void
		{
			var classObject:Class;
			if (dataType)
			{
				switch(dataType)
				{
					case ArgonautConstants.BOOLEAN:
					case ArgonautConstants.NUMBER:
					case ArgonautConstants.STRING:
						classObject = null;
						break;
					default:
						classObject = getDefinitionByName(dataType) as Class;
						break;
				}
			}

			var aa:uint = json.length;
			for (var a:uint = 0; a < aa; a++)
			{
				if (classObject)
				{
					var element:* = new classObject();
					retv[a] = parseElement(element, json[a]);
				}
				else
				{
					retv[a] = json[a];
				}
			}
		}

		/**
		 * Does the provided json have a property that marks it as a participant?
		 * 
		 * By default, this property would be __alias
		 * 
		 * @param json A JSON object
		 * 
		 * @return True if this is a participating class
		 */
		private static function isParticipant(json:Object):Boolean
		{
			var aliasId:String = JSONDecoder.config.aliasId;
			return json.hasOwnProperty(aliasId);
		}

		/**
		 * Set the value on an Object
		 * 
		 * @param retv	The return value we're passing around
		 * @param key	The key to the property we're currently parsing
		 * @param value	The value of the key
		 * 
		 * @return The modified retv
		 */
		private static function setValue(retv:*, key:String, value:*):*
		{
			retv[key] = value;
			return retv;
		}

		/**
		 * Handle decoding errors
		 * 
		 * @param e An error
		 */
		private static function handleError(e:Error):void
		{
			var decodeErrorHandleMode:String = JSONDecoder.config.decodeErrorHandleMode;
			switch(decodeErrorHandleMode)
			{
				case ArgonautConstants.DECODE_ERROR_IGNORE:
					return;
				case ArgonautConstants.DECODE_ERROR_TRACE:
					trace(e.message);
					return;
				case ArgonautConstants.DECODE_ERROR_ERROR:
					throw (e);
			}
		}
	}
}
