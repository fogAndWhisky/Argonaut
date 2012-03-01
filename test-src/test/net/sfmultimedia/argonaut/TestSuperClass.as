package test.net.sfmultimedia.argonaut
{
	import flash.text.TextField;
	/**
	 * @author mtanenbaum
	 */
	public class TestSuperClass
	{
		
		public var aNumber:Number;
		
		public var anInt:int;
		
		public var aUint:uint;
		
		public var aBoolean:Boolean;
		
		public var aString:String;
		
		public var anArray:Array;
		
		public var aStar:*;
		
		public var anObject:Object;
		
		public var aComplexObject:TextField;
		
		public const aConstant:String = "Phineas";

		//Everything below this line shouldn't be serialized
		[DontSerialize]
		public var aNonserialized:String;
		
		[DontSerialize]
		public const aConstantSuppressed:String = "Creusa";
		
		public static var aStaticVar:String;
		
		public function aFunction():void{};
	}
}
