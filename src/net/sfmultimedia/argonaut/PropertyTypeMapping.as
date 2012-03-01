package net.sfmultimedia.argonaut
{
	/**
	 * <p>Mapping record of each of a class's properties</p>
	 * 
	 * @author mtanenbaum
	 */
	public class PropertyTypeMapping
	{
		/** The data type, exactly as it comes out of reflection */
		public var type:String;
		
		/** The data type, normalized if possible to a "standard" data type (e.g., int, uint and Number all become Number) */
		public var normalizedType:String;
		
		/** For Vectors only, the type of the Vector's element */
		public var elementType:String;
		
		/** For Vectors only, the Vector element's data type, normalized if possible to a "standard" data type (e.g., int, uint and Number all become Number)  */
		public var elementNormalizedType:String;
	}
}
