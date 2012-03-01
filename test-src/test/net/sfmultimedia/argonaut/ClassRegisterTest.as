package test.net.sfmultimedia.argonaut
{
	import net.sfmultimedia.argonaut.PropertyTypeMapping;
	import avmplus.getQualifiedClassName;

	import net.sfmultimedia.argonaut.ClassRegister;

	import org.flexunit.Assert;

	import flash.display.Sprite;
	import flash.net.getClassByAlias;
	import flash.text.TextField;

	/**
	 * @author mtanenbaum
	 */
	public class ClassRegisterTest extends Sprite
	{
		
		[Test]
		public function registerClassAlias() : void 
		{
			ClassRegister.registerClassAlias("flash.display.Sprite", Sprite);
			
			var registeredClass:Class = flash.net.getClassByAlias("flash.display.Sprite");
			
			Assert.assertNotNull("The class alias did not register correctly and came back null", registeredClass);
			Assert.assertTrue("The class alias did not register to the specified Class", registeredClass == Sprite);
		}
		 
		[Test]
		public function flush() : void 
		{
			ClassRegister.registerClassAlias("flash.display.Sprite", Sprite);
			var registeredClass:Class = ClassRegister.getClassByAlias("flash.display.Sprite");
			Assert.assertTrue("The class alias did not register to the specified Class", registeredClass == Sprite);
			
			ClassRegister.flush();
			
			var registeredClassAfterFlush:Class = ClassRegister.getClassByAlias("flash.display.Sprite");
			Assert.assertNull("The register should be empty, but the previously registered class Sprite isn't null", registeredClassAfterFlush);
		}
		
		[Test]
		public function getClassByAlias() : void 
		{
			ClassRegister.registerClassAlias("flash.display.Sprite", Sprite);
			
			var registeredClass:Class = ClassRegister.getClassByAlias("flash.display.Sprite");
			
			Assert.assertNotNull("The class alias did not register correctly and came back null", registeredClass);
			Assert.assertTrue("The class alias did not register to the specified Class", registeredClass == Sprite);
		}
		
		[Test]
		public function registerClass() : void 
		{
			ClassRegister.registerClass(Sprite);
			
			var isRegisteredClassRegistered:Boolean = ClassRegister.isClassRegistered(Sprite);
			var isNonregisteredClassRegistered:Boolean = ClassRegister.isClassRegistered(TextField);
			
			Assert.assertTrue("The registered class did not report as being registered", isRegisteredClassRegistered);
			Assert.assertFalse("The non-registered class somehow came back as registered", isNonregisteredClassRegistered);
		}
		
		[Test]
		public function registerClassByInstance() : void 
		{
			var instance:Sprite = new Sprite();
			var clazz:Object = ClassRegister.registerClassByInstance(instance);
			
			Assert.assertNotNull("Mapping an instance to registerClassByInstance should return a class", clazz);
			Assert.assertTrue("Mapped a Sprite, but the class returned was " + getQualifiedClassName(clazz), clazz == Sprite);
			
			var isRegisteredClassRegistered:Boolean = ClassRegister.isClassRegistered(Sprite);
			var isNonregisteredClassRegistered:Boolean = ClassRegister.isClassRegistered(TextField);
			
			Assert.assertTrue("The registered class did not report as being registered", isRegisteredClassRegistered);
			Assert.assertFalse("The non-registered class somehow came back as registered", isNonregisteredClassRegistered);
		}
		
		[Test]
		public function getClassMap() : void 
		{
			ClassRegister.flush();
			
			Assert.assertNull("There shouldn't be any classes registered at this time", ClassRegister.getClassMap(Sprite));
			
			ClassRegister.registerClass(Sprite);
			
			var classMap:Object = ClassRegister.getClassMap(Sprite);
			
			Assert.assertNotNull("A registered failed to return a map", classMap);
			
			var mapping:PropertyTypeMapping = classMap["x"];
			var propType:String = mapping.type;
			//Test number mapping
			Assert.assertNotNull("Mapped a Sprite, but the classMap didn't have the 'x' property", propType);
			Assert.assertTrue("Mapped Sprite, but the classMap's 'x' property maps to " + propType + " instead of Number", propType == "Number");
			//Test String mapping
			mapping = classMap["name"];
			propType = mapping.type;
			Assert.assertTrue("Mapped Sprite, but the classMap's 'name' property maps to " + propType + " instead of String", propType == "String");
			//Test Object mapping
			mapping = classMap["cacheAsBitmap"];
			propType = mapping.type;
			Assert.assertTrue("Mapped Sprite, but the classMap's 'cacheAsBitmap' property maps to " + propType + " instead of Boolean", propType == "Boolean");
			//Test Object mapping
			mapping = classMap["focusRect"];
			propType = mapping.type;
			Assert.assertTrue("Mapped Sprite, but the classMap's 'focusRect' property maps to " + propType + " instead of Object", propType == "Object");
			//Test First Class mapping
			mapping = classMap["graphics"];
			propType = mapping.type;
			Assert.assertTrue("Mapped Sprite, but the classMap's 'graphics' property maps to " + propType + " instead of flash.display::Graphics", propType == "flash.display::Graphics");
		}
	}
}
