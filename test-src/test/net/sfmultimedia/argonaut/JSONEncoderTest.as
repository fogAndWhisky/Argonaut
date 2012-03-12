package test.net.sfmultimedia.argonaut
{
	import net.sfmultimedia.argonaut.ClassRegister;
	import net.sfmultimedia.argonaut.JSONEncoder;

	import org.flexunit.Assert;

	import flash.display.Sprite;
	import flash.text.TextField;

	/**
	 * @author mtanenbaum
	 */
	public class JSONEncoderTest extends Sprite
	{
		private var instance:TestSubClass;
		

		[AfterClass]
		public static function teardown() : void
		{
			ClassRegister.flush();
		}
		
		[Before]
		public function setupStringify():void
		{
			instance = new TestSubClass();
			instance.aBoolean = true;
			instance.aComplexObject = new TextField();
			instance.aComplexObject.text = "Thessalus";
			instance.aComplexObject.x = 20.5;
			instance.aComplexObject.y = 100;
			instance.anArray = [true, 3.14, "third item", {fourthString:"Chiron"}];
			instance.anInt = -100;
			instance.anObject = {anObjectFalse:false, anObjectTrue:true, anObjectObject:{anObjectObjectString:"Talos"}};
			instance.aNonserialized = "This shouldn't get serialized";
			instance.aNumber = 102.25;
			instance.aNumberInSubClass = 999;
			instance.aStar = {aStarString:"Phineas", aStarNumber:7};
			instance.aString = "Hera";
			instance.aUint = 100;
			
			var complexElements:Array = [new TestVectorElement("Heracles", 30), new TestVectorElement("Bellerophon", 21), new TestVectorElement("Castor", 22)];
			instance.aVectorOfComplexity = Vector.<TestVectorElement>(complexElements);
			
			var simpleElements:Array = ["Heracles", "Bellerophon", "Castor"];
			instance.aVectorOfStrings = Vector.<String>(simpleElements);
		}
		
		[Test]
		public function stringify():void
		{
			var jsonString:String = JSONEncoder.stringify(instance);
			var json:Object = JSON.parse(jsonString);
			assertValues(json);
		}
		
		[Test]
		public function stringifyWithPrettyPrint():void
		{
			var jsonString:String = JSONEncoder.stringify(instance, null, true);
			
			trace(jsonString);
			
			var json:Object = JSON.parse(jsonString);
			assertValues(json);
		}
		
		private function assertValues(obj:*):void
		{
			Assert.assertEquals("test.net.sfmultimedia.argonaut::TestSubClass", obj.__jsonclass__);
			Assert.assertEquals(102.25, obj.aNumber);
			Assert.assertEquals(-100, obj.anInt);
			Assert.assertEquals(100, obj.aUint);
			Assert.assertEquals(true, obj.aBoolean);
			Assert.assertEquals("Hera", obj.aString);
			
			Assert.assertEquals(true, obj.anArray[0]);
			Assert.assertEquals(3.14, obj.anArray[1]);
			Assert.assertEquals("third item", unescape(obj.anArray[2]));	//unescape required, since we escape outbound JSON
			Assert.assertEquals("Chiron", obj.anArray[3].fourthString);
			
			Assert.assertEquals("Phineas", obj.aStar.aStarString);
			Assert.assertEquals(7, obj.aStar.aStarNumber);
			
			Assert.assertEquals(false, obj.anObject.anObjectFalse);
			Assert.assertEquals(true, obj.anObject.anObjectTrue);
			Assert.assertEquals("Talos", obj.anObject.anObjectObject.anObjectObjectString);
			
			Assert.assertEquals("Thessalus", obj.aComplexObject.text);
			Assert.assertEquals(20.5, obj.aComplexObject.x);
			Assert.assertEquals(100, obj.aComplexObject.y);
			Assert.assertEquals(999, obj.aNumberInSubClass);
			
			Assert.assertEquals(obj.aVectorOfComplexity[0].name, "Heracles");
			Assert.assertEquals(obj.aVectorOfComplexity[1].name, "Bellerophon");
			Assert.assertEquals(obj.aVectorOfComplexity[2].name, "Castor");
			
			Assert.assertEquals(obj.aVectorOfComplexity[0].age, 30);
			Assert.assertEquals(obj.aVectorOfComplexity[1].age, 21);
			Assert.assertEquals(obj.aVectorOfComplexity[2].age, 22);
			
			Assert.assertEquals(obj.aVectorOfStrings[0], "Heracles");
			Assert.assertEquals(obj.aVectorOfStrings[1], "Bellerophon");
			Assert.assertEquals(obj.aVectorOfStrings[2], "Castor");
			
			Assert.assertEquals("Phineas", obj.aConstant);
			
			//These should not survive the serialization process
			Assert.assertNull(obj.aNonserialized);
			Assert.assertNull(obj.aConstantSuppressed);
		}
	}
}
