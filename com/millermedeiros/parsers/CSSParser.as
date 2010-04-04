/**
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */

package com.millermedeiros.parsers {
	
	import com.millermedeiros.utils.StringUtils;
	
	/**
	 * Simple CSS parser - (Obs: doesn't implement any kind of inheritance)
	 * - Based on flash.text.StyleSheet but supports any kind of element and property
	 * @author Miller Medeiros (http://www.millermedeiros.com/)
	 * @version 0.1 (2009/09/18)
	 */
	public class CSSParser {
		
		private var _css:Object;
		
		/**
		 * Constructor
		 */
		public function CSSParser() {
			_css = {};
		}
		
		/**
		 * Parse CSS into a Object
		 * @param	cssStr
		 */
		public function parseCSS(cssStr:String):void {
			cssStr = StringUtils.removeAllComments(cssStr); //remove comments
			var cssArr:Array = cssStr.match(/([\w \.:\#]+\{.+?\})/gs); //split all slectors{properties:values}
			parseSelectors(cssArr);
		}
		
		/**
		 * Parse all selectors and properties
		 * @param	cssArr	Array<String>
		 */
		private function parseSelectors(cssArr:Array):void {
			var selector:String;
			var properties:String;
			var n:int = cssArr.length;
			for (var i:int = 0; i < n; i++) {
				selector = StringUtils.trim(cssArr[i].match(/.+(?=\{)/g)[0]); //everything before {
				properties = cssArr[i].match(/(?<=\{).+(?=\})/g)[0]; //everything inside {}
				setStyle(selector, parseProperties(properties));
			}
		}
		
		/**
		 * Convert properties String into an Object
		 * @param	propStr	String with all properties
		 */
		private function parseProperties(propStr:String):Object {
			var result:Object = {};
			var properties:Array = propStr.match(/\b\w[\w-:\#\/ ,]+/g); //split properties
			var curProp:Array;
			var n:int = properties.length;
			for (var j:int = 0; j < n; j++) {
				curProp = properties[j].split(":");
				result[StringUtils.toCamelCase(curProp[0])] = StringUtils.trim(curProp[1]);
			}
			return result;
		}
		
		/**
		 * Array with all selectors name
		 */
		public function get selectors():Array {
			var selectors:Array = [];
			for (var prop in _css) {
				selectors.push(prop);
			}
			return selectors;
		}
		
		/**
		 * get Style object associated with the selector
		 */
		public function getStyle(selector:String):Object { return _css[selector]; }
		
		/**
		 * Set style object
		 * @param	selector
		 * @param	styleObj
		 */
		public function setStyle(selector:String, styleObj:Object):void {
			if (_css[selector] === undefined) _css[selector] = { };
			_css[selector] = styleObj;
		}
		
		/**
		 * Remove all selectors and properties
		 */
		public function clear() { _css = {}; }
		
	}
	
}
