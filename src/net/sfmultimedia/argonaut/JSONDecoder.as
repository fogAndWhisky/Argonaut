package net.sfmultimedia.argonaut
{
    import flash.events.EventDispatcher;
    import flash.utils.getDefinitionByName;

    /**
     * <p>Responsible for converting raw JSON into Classes</p>
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
    public class JSONDecoder extends EventDispatcher
    {

        /** The configuration of the current Argonaut instance */
        private var _config:ArgonautConfig;

        private var classRegister:ClassRegister;

        public function JSONDecoder(config:ArgonautConfig, classRegister:ClassRegister)
        {
            this.config = config;
            this.classRegister = classRegister;
        }


        /**
         * Generate a Class instance from JSON by matching its foreign alias to a previously mapped alias.
         *
         * This method works ONLY with participating services or primitives.
         *
         * @param json		The json Object
         *
         * @return Whatever gets generated through the deserialization process
         */
        public function generate(json:Object):*
        {
            var aliasId:String = config.aliasId;

            //Gate nulls, so we don't explode
            if (json == null)
            {
                handleError(new Error("Cannot generate from a null object"));
                return null;
            }

            // Handle primitives
            if (json is Array)
            {
                return parseElement([], json);
            }
            else if (json is Boolean || json is Number || json is String)
            {
                return json;
            }

            // If class not mapped, throw an error
            if (!isParticipant(json))
            {
                throw new Error("ArgonautJSONDecoder.generate only works on participating classes. The JSON provided must have an " + aliasId + " property defined. See generateAs instead.");
            }
            else if (!classRegister.getClassByAlias(json[aliasId]))
            {
                // The object was passed through generate, but we have no mapping.
                // We can recurse trough it and see if any properties can be mapped
                return parseElement({}, json);
            }
            else
            {
                return generateAs(json, classRegister.getClassByAlias(json[aliasId]));
            }
        }

        /**
         * Generate a Class instance from JSON by providing the class to generate.
         *
         * @param json			The json Object
         * @param classObject	The class into which we wish to convert this json
         *
         * @return An instantiated instance
         */
        public function generateAs(json:Object, classObject:Class):*
        {
            // Ensure class is registered.
            classRegister.registerClass(classObject);

            // Start parsing
            return parseElement(new classObject(), json);
        }

        /**
         * Recursively parse the nodes of the json data and assign it to the return value
         *
         * This method is highly armored against failure, since a lot can go wrong at this point.
         * If the property is read-only, or a class requires constructor arguments, things can go awry.
         *
         * @throws ArgonautErrorEvent.DECODE_ERROR
         *
         * @param retVal	The instance we're constructing
         * @param json		The data with which we're populating the instance
         *
         * @return The instance
         */
        private function parseElement(retv:*, json:Object):*
        {
            var classObject:Class;
            var classMap:Object;

            classObject = classRegister.registerClassByInstance(retv);
            classMap = classRegister.getClassMap(classObject);

            for (var key:String in json)
            {
                var value:Object = json[key];
                var mapping:PropertyTypeMapping = classMap[key];

                if (mapping == null)
                {
                    // No mapping. Use the JSON value.
                    if (value is Boolean || value is Number || value is String)
                    {
                        // Simple values simply get assigned
                        try
                        {
                            setValue(retv, key, value);
                        }
                        catch(e:Error)
                        {
                            handleError(e);
                        }
                    }
                    else if (value is Array)
                    {
                        // Arrays get recursively parsed
                        try
                        {
                            retv[key] = [];
                            parseList(retv[key], value as Array);
                        }
                        catch(e:Error)
                        {
                            handleError(e);
                        }
                    }
                    else if (value[config.aliasId])
                    {
                        //It's an object that wants to be a class
                        var co:Class = classRegister.getClassByAlias(value[config.aliasId]);
                        if (co)
                        {
                            retv[key] = new co();
                            parseElement(retv[key], value);
                        }
                        else
                        {
                            //Couldn't find a matching class. Default to treating it as a generic object
                            try
                            {
                                retv[key] = {};
                                parseElement(retv[key], value);
                            }
                            catch(e:Error)
                            {
                                handleError(e);
                            }
                        }
                    }
                    else
                    {
                        // It's an object and we have no mapping
                        try
                        {
                            retv[key] = {};
                            parseElement(retv[key], value);
                        }
                        catch(e:Error)
                        {
                            handleError(e);
                        }
                    }
                }
                else
                {
                    switch(mapping.normalizedType)
                    {
                        case ArgonautConstants.BOOLEAN:
                        case ArgonautConstants.NUMBER:
                        case ArgonautConstants.STRING:
                            // Simple values simply get assigned
                            try
                            {
                                setValue(retv, key, value);
                            }
                            catch(e:Error)
                            {
                                handleError(e);
                            }
                            break;
                        case ArgonautConstants.ARRAY:
                            // Arrays get recursively parsed
                            try
                            {
                                retv[key] = [];
                                //parseElement(retv[key], value);
                                parseList(retv[key], value as Array);
                            }
                            catch(e:Error)
                            {
                                handleError(e);
                            }
                            break;
                        case ArgonautConstants.VECTOR:
                            // Vectors get recursively parsed
                            try
                            {
                                if (retv[key] == null)
                                {
                                    handleError(new Error("WARNING: Since Adobe Player doesn't support Generics, Vectors need to have a default instantiation in the client class in order to be deserialized."));
                                }

                                // parseElement(retv[key], value);
                                var elementType:String = (mapping.elementNormalizedType == null) ? mapping.elementType : mapping.elementNormalizedType;
                                parseList(retv[key], value as Array, elementType);
                            }
                            catch(e:Error)
                            {
                                handleError(e);
                            }
                            break;
                        case ArgonautConstants.OBJECT:
                            // It's typed to Object or *
                            try
                            {
                                retv[key] = {};
                                parseElement(retv[key], value);
                            }
                            catch(e:Error)
                            {
                                handleError(e);
                            }
                            break;
                        default:
                            try
                            {
                                var valueClass:Object = getDefinitionByName(mapping.type) as Class;
                                retv[key] = new valueClass();
                                parseElement(retv[key], value);
                            }
                            catch(e:Error)
                            {
                                handleError(e);
                            }
                            break;
                    }
                }
            }

            return retv;
        }

        /**
         * Loop through a list, instantiating elements of dataType when provided
         *
         * @throws ArgonautErrorEvent.DECODE_ERROR
         */
        private function parseList(retv:*, json:Array, dataType:String = null):void
        {
            var classObject:Class;
            var alternateClassObject:Class;
            var element:*;
            if (dataType)
            {
                switch(dataType)
                {
                    case ArgonautConstants.BOOLEAN:
                    case ArgonautConstants.NUMBER:
                    case ArgonautConstants.STRING:
                        classObject = null;
                        break;
                    default:
                        classObject = getDefinitionByName(dataType) as Class;
                        break;
                }
            }

            var aa:uint = json.length;

            for (var a:uint = 0; a < aa; a++)
            {
                if (classObject)
                {
                    //A vector is a list of a type, but that type can include sub-classes.
                    //Allow a JSON element to override the default element type.
                    if (json[a][config.aliasId] != null)
                    {
                        alternateClassObject = classRegister.getClassByAlias(json[a][config.aliasId]);
                        //We found a class object
                        if (alternateClassObject)
                        {
                            element = new alternateClassObject();
                            if (!element is classObject)
                            {
                                handleError(new Error("WARNING::Attempt to instantiate " + alternateClassObject + " in a vector of type " + classObject + ". " + alternateClassObject + " does not sublcass " + classObject));
                                alternateClassObject = null;
                                element = null;
                            }
                        }

                    }
                    if (!element)
                    {
                        element = new classObject();
                    }
                    retv[a] = parseElement(element, json[a]);

                    alternateClassObject = null;
                    element = null;
                }
                else
                {
                    retv[a] = json[a];
                }
            }
        }

        /**
         * Does the provided json have a property that marks it as a participant?
         *
         * By default, this property would be __alias
         *
         * @param json A JSON object
         *
         * @return True if this is a participating class
         */
        private function isParticipant(json:Object):Boolean
        {
            var aliasId:String = config.aliasId;
            return json.hasOwnProperty(aliasId);
        }

        /**
         * Set the value on an Object
         *
         * @param retv	The return value we're passing around
         * @param key	The key to the property we're currently parsing
         * @param value	The value of the key
         *
         * @return The modified retv
         */
        private function setValue(retv:*, key:String, value:*):*
        {
            retv[key] = value;
            return retv;
        }

        public function get config():ArgonautConfig
        {
            return _config;
        }

        public function set config(value:ArgonautConfig):void
        {
            _config = value;
        }

        /**
         * Dispatch decoding errors to the ErrorHandler
         *
         * @param e An error
         */
        private function handleError(e:Error):void
        {
            dispatchEvent(new ArgonautErrorEvent(ArgonautErrorEvent.DECODING_ERROR, e));
        }
    }
}
