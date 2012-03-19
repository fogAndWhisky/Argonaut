package net.sfmultimedia.argonaut
{
	/**
	 * An interface for Argonaut. When using dependency injection, inject this interface
	 * for flexibility
	 * 
	 * @author mtanenbaum
	 */
	public interface IArgonaut
	{
		/**
		 * Override default configuration
		 * 
		 * @param value A changed configuration
		 * 
		 * @see net.sfmultimedia.argonaut.ArgonautConfig
		 */
		function setConfiguration(value:ArgonautConfig):void;
		
		/**
		 * Get the configuration
		 * 
		 * @return An ArgonautConfig
		 */
		function getConfiguration():ArgonautConfig;
		
		/**
		 * Map the remote classname to a local class.
		 * 
		 * @param aliasName 	The alias to use, probably the fully-qualified class name of the remote class.
		 * @param classObject	The Actionscript class to which we map the alias
		 */
		function registerClassAlias(aliasName:String, classObject:Class):void;
		
		/**
		 * Generate a Class instance from JSON.
		 * 
		 * This method works ONLY with participating services or primitives.
		 * 
		 * @param json	Either an object decoded by JSON.parse() into an object or a JSON-encoded String
		 * 
		 * @return Whatever gets generated through the deserialization process
		 */
		function generate(json:*):*;
		
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
		function generateAs(json:*, classObject:Class):*;
		
		/**
		 * Serialize the class's public instance properties into JSON
		 * 
		 * @param instance	The instance we want to process
		 * @param pretty	If true, result will be pretty-printed
		 * 
		 * @return The instance expressed as a JSON string
		 */
		function stringify(instance:*, pretty:Boolean = false):String;
	}
}
