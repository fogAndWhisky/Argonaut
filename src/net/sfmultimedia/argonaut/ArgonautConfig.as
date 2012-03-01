package net.sfmultimedia.argonaut
{
	/**
	 * <p>These values can be overridden to change Argonaut behavior</p>
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
	public class ArgonautConfig
	{
		/**
		 * The property to use to identify the remote class identifier. By default, this value is "__jsonclass__",
		 * which is consistent with <a href="http://json-rpc.org">json-rpc</a>, but it can be re-set here to anything.
		 */
		public var aliasId:String = "__jsonclass__";
		
		/**
		 * By default, all complex objects get tagged with the aliasId during serialization.
		 * Set this to false to suppress tagging.
		 */
		public var tagClassesWhenEncoding:Boolean = true;
		
		/**
		 * If set to true, encoding uses AS-native JSON.stringify()
		 * 
		 * Native mode is internally faster, but won't respect [DontSerialize] tags and won't automatically add
		 * an alias tag.
		 */
		public var nativeEncodeMode:Boolean = false;
		
		/**
		 * How should Argonaut behave when it runs into errors while decoding?
		 * 
		 * By default, we simply catch and trace the errors (equivalent to AMF). Other options:
		 * ArgonautConstants.DECODE_ERROR_ERROR - Throw errors
		 * ArgonautConstants.DECODE_ERROR_IGNORE - Do nothing at all, not even trace
		 */
		public var decodeErrorHandleMode:String = ArgonautConstants.DECODE_ERROR_TRACE;
		
	}
}
