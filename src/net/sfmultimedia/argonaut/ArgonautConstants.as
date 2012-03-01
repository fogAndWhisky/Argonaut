package net.sfmultimedia.argonaut
{
	/**
	 * <p>Constants used internally by Argonaut.</p>
	 * 
	 * <p>The public <code>DECODE_ERROR</code> constants may be set on a configuration in order to change error reporting behavior.</p>
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
	public class ArgonautConstants
	{
		/** @private Any Actionscript property that should not be serialized needs to be metatagged with this */
		internal static const DONT_SERIALIZE:String = "DontSerialize";
		
		/** @private The class-type representing Booleans */
		internal static const BOOLEAN:String = "Boolean";
		
		/** @private The class-type representing String */
		internal static const STRING:String = "String";
		
		/** @private The class-type representing all numerical values (Number, int, uint) */
		internal static const NUMBER:String = "Number";
		/** @private uint type */
		internal static const UINT:String = "uint";
		/** @private int type */
		internal static const INT:String = "int";
		
		/** @private The class-type representing all Object values (Object and *) */
		internal static const OBJECT:String = "Object";
		/** @private Star will also be serialized as Object */
		internal static const STAR:String = "*";
		
		/** @private The class-type representing Array values */
		internal static const ARRAY:String = "Array";
		
		/** @private The class-type representing all Vector values */
		internal static const VECTOR:String = "__AS3__.vec::Vector.";
		
		/** When decoding causes errors, throw an Error */
		public static const DECODE_ERROR_ERROR:String = "DECODE_ERROR_ERROR";
		
		/** When decoding causes errors, trace out the error message (default) */
		public static const DECODE_ERROR_TRACE:String = "DECODE_ERROR_TRACE";
		
		/** When decoding causes errors, ignore them */
		public static const DECODE_ERROR_IGNORE:String = "DECODE_ERROR_IGNORE";
	}
}
