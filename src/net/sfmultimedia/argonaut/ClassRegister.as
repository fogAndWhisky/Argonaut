package net.sfmultimedia.argonaut
{
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.net.registerClassAlias;
	import flash.net.getClassByAlias;
	
	/**
	 * <p>Responsible for registering classes and mapping their non-static properties.</p>
	 * 
	 * <p>Classes may be mapped because they are being shared across the application boundary,
	 * or simply in the process of serialization.</p>
	 * 
	 * <p>Note that some data types get "normalized" to ensure clean reflection to JSON data types.
	 * For example, int, uint and Number are all just Number to JSON (and to AS3, really), so any
	 * values typed to int, uint or Number will be mapped to "Number".</p>
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
	public class ClassRegister
	{
		
		/** A dictionary of all mapped classes, keyed to the class. The values are hash maps of all public properties and their data type */
		private static var register:Dictionary = new Dictionary();
		
		/**
		 * <p>Clear the class register</p>
		 * 
		 * <p>Warning: as the name implies, calling this method will remove all your prior registrations. This is useful
		 * for testing, but is unlikely ever to be needed at runtime.</p>
		 */
		public static function flush():void
		{
			register = new Dictionary();
		}
		
		/**
		 * Map the remote classname to a local class.
		 * 
		 * @param aliasName 	The alias to use, probably the fully-qualified class name of the remote class.
		 * @param classObject	The Actionscript class to which we map the alias
		 */
		public static function registerClassAlias(aliasName:String, classObject:Class):void
		{
			flash.net.registerClassAlias(aliasName, classObject);
			registerClass(classObject);
		}
		
		/**
		 * Retrieve a mapped class.
		 * 
		 * @param aliasName 	The alias to use, probably the fully-qualified class name of the remote class.
		 * 
		 * @return The mapped Class, or null if no mapping
		 */
		public static function getClassByAlias(aliasName:String):Class
		{
			var classObject:Class = flash.net.getClassByAlias(aliasName);
			
			if (register[classObject])
			{
				return classObject;
			}
			return null;
		}
		
		/**
		 * Generate a description of the provided class for future use.
		 * 
		 * @param classObject	The Actionscript class to which we map the alias
		 */
		public static function registerClass(classObject:Class):void
		{
			if (register[classObject])
			{
				return;
			}
			
			register[classObject] = explodeClass(classObject);
		}
		
		/**
		 * Use an instance to register its Class
		 * 
		 * @param instance	The instance of a Class we want to register
		 */
		public static function registerClassByInstance(instance:*):Class
		{
			var classObject:Class = getClassFromInstance(instance);
			registerClass(classObject);
			return classObject;
		}
		
		/**
		 * Has this class been regstered?
		 * 
		 * @param classObject	The class we're looking for
		 * 
		 * @return True if the class has been registered
		 */
		 public static function isClassRegistered(classObject:Class):Boolean
		 {
			return Boolean(register[classObject]);
		 }
		
		/**
		 * Get the property map for the provided class
		 * 
		 * @param classObject	The class we're looking to map
		 * 
		 * @return The hash map of property names and types
		 */
		 public static function getClassMap(classObject:Class):Object
		 {
			return register[classObject];
		 }
		
		/**
		 * Dig through the class description, mapping its properties to data types.
		 * 
		 * @param classObject	The class we're mapping
		 * 
		 * @return	The resulting property > data type map
		 */
		private static function explodeClass(classObject:Class):Object
		{
			var xmlDescriptionOfClass:XML = describeType(classObject);
			var nonstaticPropertiesXML:XMLList = xmlDescriptionOfClass.factory.variable;
			var nonstaticAccessorsXML:XMLList = xmlDescriptionOfClass.factory.accessor;
			var nonstaticConstantsXML:XMLList = xmlDescriptionOfClass.factory.constant;
			
			var properties:Object = {};
			var node:XML;
			var name:String;
			var mapping:PropertyTypeMapping;
			
			for each (node in nonstaticPropertiesXML)
			{
				name = node.@name;
				mapping = generateMapping(node);
				if (mapping)
				{
					properties[name] = mapping;
				}
			}
			
			for each (node in nonstaticAccessorsXML)
			{
				name = node.@name;
				mapping = generateMapping(node);
				if (mapping)
				{
					properties[name] = mapping;
				}
			}
			
			for each (node in nonstaticConstantsXML)
			{
				name = node.@name;
				mapping = generateMapping(node);
				if (mapping)
				{
					properties[name] = mapping;
				}
			}
			
			return properties;
		}
		
		/**
		 * <p>Force nodes to obey our rule set:</p>
		 * 
		 * <ul>
		 * <li>Dont serialize anything marked "DontSerialize"</li>
		 * <li>Dont serialize anything that's marked writeonly (an accessor with a setter, but no getter)</li>
		 * <li>Simplify data types to match JSON (all Number types = Number, Object and * = Object)</li>
		 * </ul>
		 * 
		 * @param node	Some XML describing a property node
		 * 
		 * @return Either null, if we're not serializing, or the normalized data type
		 */
		private static function generateMapping(node:XML):PropertyTypeMapping
		{
			var mapping:PropertyTypeMapping = new PropertyTypeMapping();
			mapping.type = node.@type;
			
			//Respect the DontSerialize metatag.
			var serialize:Boolean = node..metadata.(@name==ArgonautConstants.DONT_SERIALIZE).length() == 0;
			if (!serialize)
			{
				return null;
			}
			//Don't serialize vars that don't have read access
			if (node.localName() == "accessor" && node.@access == "writeonly")
			{
				return null;
			}

			//Vectors are a special case. We need to know both its nature as a Vector and the data type of its elements
			if (mapping.type.indexOf(ArgonautConstants.VECTOR) > -1)
			{
				mapping.normalizedType = ArgonautConstants.VECTOR;
				mapping.elementType = mapping.type.substring(mapping.type.indexOf("<") + 1, mapping.type.indexOf(">"));
				mapping.elementNormalizedType = normalize(mapping.elementType);
			}
			else
			{
				mapping.normalizedType = normalize(mapping.type);
			}
			
			return mapping;
		}

		/**
		 * Take a data type and attempt to normalize it to an understood JSON mapping
		 * 
		 * @param type The data type as read directly from reflection
		 * 
		 * @return The normalized type, or null if no normalization was possible
		 */
		private static function normalize(type:String):String
		{
			// The following datatypes are "normal". Anything that falls through the switch statement
			// represents something not ordinarily supported by JSON.
			switch(type)
			{
				case ArgonautConstants.BOOLEAN:
					return ArgonautConstants.BOOLEAN;
					break;
				case ArgonautConstants.STRING:
					return ArgonautConstants.STRING;
					break;
				case ArgonautConstants.INT:
				case ArgonautConstants.NUMBER:
				case ArgonautConstants.UINT:
					return ArgonautConstants.NUMBER;
					break;
				case ArgonautConstants.STAR:
				case ArgonautConstants.OBJECT:
					return ArgonautConstants.OBJECT;
					break;
				case ArgonautConstants.ARRAY:
					return ArgonautConstants.ARRAY;
					break;
			}
			return null;
		}
		
		/**
		 * Get the class of the instance we want to parse
		 * 
		 * @param instance	The instance we're parsing
		 * 
		 * @return The Class to which the instance belongs
		 */
		private static function getClassFromInstance(instance:*):Class
		{
			//Get the class from the instance
			var classObject:Class = instance.constructor as Class;

			//Handle the case of Proxy subclasses
			if (classObject == null)
			{
				var fqcn:String = getQualifiedClassName(instance);
				classObject = getDefinitionByName(fqcn) as Class;
			}
			
			return classObject;
		}
	}
}
