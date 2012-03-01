package test.net.sfmultimedia.argonaut
{
	import net.sfmultimedia.argonaut.ClassRegister;
	import net.sfmultimedia.argonaut.JSONDecoder;

	import org.flexunit.Assert;
	import org.flexunit.async.Async;

	import mx.utils.StringUtil;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;

	/**
	 * @author mtanenbaum
	 */
	public class JSONDecoderTest extends Sprite
	{

		private static var PARTICIPATING_URL:String = "test/data/participating.json";
		private static var json:Object = {};
		private static const urlLoader : URLLoader = new URLLoader();

		[BeforeClass(async, timeout="3000")]
		public static function loadJSON():void
		{
			const urlRequest:URLRequest = new URLRequest(PARTICIPATING_URL);
			Async.proceedOnEvent(JSONDecoderTest, urlLoader, Event.COMPLETE);

			try
			{
				urlLoader.load(urlRequest);
			}
			catch (error : Error)
			{
				Assert.fail("urlLoader threw: " + error);
			}

			urlLoader.addEventListener(Event.COMPLETE, Async.asyncHandler(JSONDecoderTest, jsonLoaded, 2000, json, jsonLoadFailed), false, 0, true);

			Async.failOnEvent(JSONDecoderTest, urlLoader, IOErrorEvent.IO_ERROR, 2000);
			Async.failOnEvent(JSONDecoderTest, urlLoader, SecurityErrorEvent.SECURITY_ERROR, 2000);
		}

		[AfterClass]
		public static function teardown() : void
		{
			json = null;
			ClassRegister.flush();
		}

		[Test(order="2")]
		public function generate() : void
		{
			ClassRegister.registerClassAlias("net.sfmultimedia.argonaut.AnAliasForTestSubClass", TestSubClass);
			var testSubClass:TestSubClass = JSONDecoder.generate(json);
			Assert.assertNotNull("generate failed to generate an instance", testSubClass);
			assertValues(testSubClass);
		}

		[Test(order="1")]
		public function generateAs() : void
		{
			var testSubClass:TestSubClass = JSONDecoder.generateAs(json, TestSubClass);
			Assert.assertNotNull("generateAs failed to generate an instance", testSubClass);
			assertValues(testSubClass);
		}
		
		private function assertValues(testSubClass:TestSubClass):void
		{
			Assert.assertEquals(102.25, testSubClass.aNumber);
			Assert.assertEquals(-100, testSubClass.anInt);
			Assert.assertEquals(100, testSubClass.aUint);
			Assert.assertEquals(true, testSubClass.aBoolean);
			Assert.assertEquals("Hera", testSubClass.aString);
			
			Assert.assertEquals(true, testSubClass.anArray[0]);
			Assert.assertEquals(3.14, testSubClass.anArray[1]);
			Assert.assertEquals("third item", testSubClass.anArray[2]);
			Assert.assertEquals("Chiron", testSubClass.anArray[3].fourthString);
			
			Assert.assertEquals("Phineas", testSubClass.aStar.aStarString);
			Assert.assertEquals(7, testSubClass.aStar.aStarNumber);
			
			Assert.assertEquals(false, testSubClass.anObject.anObjectFalse);
			Assert.assertEquals(true, testSubClass.anObject.anObjectTrue);
			Assert.assertEquals("Talos", testSubClass.anObject.anObjectObject.anObjectObjectString);
			
			Assert.assertTrue(testSubClass.aComplexObject is TextField);
			Assert.assertEquals("Thessalus", testSubClass.aComplexObject.text);
			Assert.assertEquals(20.5, testSubClass.aComplexObject.x);
			Assert.assertEquals(100, testSubClass.aComplexObject.y);
			Assert.assertEquals(999, testSubClass.aNumberInSubClass);
			
			Assert.assertEquals("Heracles", testSubClass.aVectorOfStrings[0]);
			Assert.assertEquals("Bellerophon", testSubClass.aVectorOfStrings[1]);
			Assert.assertEquals("Castor", testSubClass.aVectorOfStrings[2]);
			
			Assert.assertTrue(testSubClass.aVectorOfComplexity[0] is TestVectorElement);
			Assert.assertTrue(testSubClass.aVectorOfComplexity[1] is TestVectorElement);
			Assert.assertTrue(testSubClass.aVectorOfComplexity[2] is TestVectorElement);
			
			Assert.assertEquals("Heracles", testSubClass.aVectorOfComplexity[0].name);
			Assert.assertEquals("Bellerophon", testSubClass.aVectorOfComplexity[1].name);
			Assert.assertEquals("Castor", testSubClass.aVectorOfComplexity[2].name);
			
			Assert.assertEquals(30, testSubClass.aVectorOfComplexity[0].age);
			Assert.assertEquals(21, testSubClass.aVectorOfComplexity[1].age);
			Assert.assertEquals(22, testSubClass.aVectorOfComplexity[2].age);
		}
		
		private static function jsonLoaded(event:Event, passThrough:*):void
		{
			Assert.assertNotNull("Data came back null", urlLoader.data);
			Assert.assertTrue("Data loaded, but has no data", 0 !== String(urlLoader.data).length);
			var jsonString:String = urlLoader.data;
			
			json = JSON.parse(jsonString);
		}
		
		private static function jsonLoadFailed(event : Event) : void
		{
			const timeoutMessage : String = StringUtil.substitute("TestCase-FATAL: preTestingConfirmServerReady failed to contact test URL \"{0}\" most tests will fail", PARTICIPATING_URL);
			trace(timeoutMessage);
			Assert.fail(timeoutMessage);
		}
	}
}
