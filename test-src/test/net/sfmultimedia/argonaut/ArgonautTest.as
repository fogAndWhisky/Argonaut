package test.net.sfmultimedia.argonaut
{
	import net.sfmultimedia.argonaut.ArgonautConstants;
	import org.flexunit.Assert;
	import net.sfmultimedia.argonaut.ArgonautConfig;
	import net.sfmultimedia.argonaut.Argonaut;
	import flash.display.Sprite;

	/**
	 * @author mtanenbaum
	 */
	public class ArgonautTest extends Sprite
	{
		[Test]
		public function getConfiguration():void
		{
			var config:ArgonautConfig = Argonaut.getConfiguration();
			//Ensure defaults as expected
			Assert.assertEquals("__jsonclass__", config.aliasId);
			Assert.assertEquals(true, config.tagClassesWhenEncoding);
			Assert.assertEquals(ArgonautConstants.DECODE_ERROR_TRACE, config.decodeErrorHandleMode);
			Assert.assertEquals(false, config.nativeEncodeMode);
			
			//Set a config and test again
			config = new ArgonautConfig();
			config.aliasId = "someOtherAlias";
			config.tagClassesWhenEncoding = false;
			config.decodeErrorHandleMode = ArgonautConstants.DECODE_ERROR_ERROR;
			config.nativeEncodeMode = true;
			Argonaut.setConfiguration(config);
			
			Assert.assertEquals("someOtherAlias", config.aliasId);
			Assert.assertEquals(false, config.tagClassesWhenEncoding);
			Assert.assertEquals(ArgonautConstants.DECODE_ERROR_ERROR, config.decodeErrorHandleMode);
			Assert.assertEquals(true, config.nativeEncodeMode);
		}
		
		[AfterClass]
		public static function teardown():void
		{
			var config:ArgonautConfig = new ArgonautConfig();
			config.aliasId = "__jsonclass__";
			config.tagClassesWhenEncoding = true;
			config.decodeErrorHandleMode = ArgonautConstants.DECODE_ERROR_TRACE;
			config.nativeEncodeMode = false;
			Argonaut.setConfiguration(config);
		}
	}
}
