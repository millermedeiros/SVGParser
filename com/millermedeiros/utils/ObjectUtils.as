package com.millermedeiros.utils {
	
	/**
	 * ObjectUtils
	 * @author Miller Medeiros (http://www.millermedeiros.com)
	 * @version	0.2
	 * @since	2009/09/21
	 */
	public class ObjectUtils {
		
		/**
		 * @private
		 */
		public function ObjectUtils() {
			throw new Error("This is a STATIC class and should not be instantiated.");
		}
		
		/**
		 * Merge 2 objects (used for inheritance)
		 * @param	base	Base object
		 * @param	extend	Object that should replace base properties
		 * @return	Attributes Object
		 */
		public static function merge(base:Object, extend:Object):Object {
			var merged:Object = {};
			for (var key:String in base) {
				merged[key] = base[key];
			}
			for (var prop:String in extend) {
				merged[prop] = extend[prop];
			}
			return merged;
		}
		
		/**
		 * Convert String to Object
		 * - Ex: ObjectUtils.toObject("{foo:bar, lorem:ipsum, dolor:123}") returns [Object] {foo:bar, lorem:ipsum, dolor:123}
		 * @param	objString	String that represents the Object
		 * @return
		 */
		public static function toObject(objString:String):Object {
			var o:Object = { };
			objString = objString.replace(/\{|\}/g, "");
			var tmpArr:Array = objString.split(",");
			var n:int = tmpArr.length;
			while (n--) {
				tmpArr[n] = String(tmpArr[n]).split(":");
				o[StringUtils.trim(tmpArr[n][0])] = StringUtils.trim(tmpArr[n][1]);
			}
			return o;
		}
		
	}
	
}