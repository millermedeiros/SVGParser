package com.millermedeiros.utils {
	
	import flash.utils.getQualifiedClassName;
	
	/**
	 * ArrayUtils
	 * @author Miller Medeiros (http://www.millermedeiros.com)
	 * @version	0.2
	 * @since	2010/02/14
	 */
	public class ArrayUtils {
		
		/**
		 * @private
		 */
		public function ArrayUtils() {
			throw new Error("This is a STATIC CLASS and should not be instantiated.");
		}
		
		/**
		 * Remove empty items (void) and return a new Array
		 */
		public static function removeEmptyItems(arr:Array):Array {
			function isNotEmpty(item:*, index:int, array:Array):Boolean {
				return (getQualifiedClassName(item) == "void")? false : true;
			}
			return arr.filter(isNotEmpty);
		}
		
		/**
		 * Sort array items randomly and return a new array
		 */
		public static function randomSort(arr:Array):Array {
			function randomize(elementA:Object, elementB:Object):int {
				var r:Number = Math.random();
				if (r < .3333333334) {
					return -1;
				}else if (r > .3333333333 && r < .6666666667) {
					return 0;
				} else {
					return 1;
				}
			}
			return arr.sort(randomize);
		}
		
		/**
		 * Return a literal representation of the Array
		 * - ex: var myArr:Array = [1,2,[30,31,"lorem", {a:"lorem", b:15}]];  ArrayUtils.toStringArray(myArr)  returns  "[1,2,[30,31,'lorem', {a:'lorem', b:15}]]"
		 */
		public static function toStringArray(arr:Array):String {
			var str:String = "[";
			function checkType(item:*, index:int, array:Array):void {
				str += (!index)? '' : ',';
				switch(getQualifiedClassName(item)) {
					case "Array":
						str += "[";
						item.forEach(checkType);
						str += "]";
						break;
					case "Object":
						str += "{";
						for (var prop:String in item) {
							str += prop + ":";
							checkType(item[prop], 0, []);
							str += ",";
						}
						str = str.substr(0, str.length - 1) + "}";
						break;
					case "String":
						str += "'" + item + "'";
						break;
					case "void":
						break;
					default:
						str += item;
				}	
			}
			arr.forEach(checkType);
			return str + "]";
		}
		
		/**
		 * Compare 2 Arrays
		 * - Check if items are on the same order and has the same type and value.
		 * @param	arr1	Array #1
		 * @param	arr2	Array #2
		 * @return	If Arrays contains same values
		 */
		public static function compare(arr1:Array, arr2:Array):Boolean{
			if(arr1.length != arr2.length){
				return false;
			}else{
				var n:int = arr1.length;
				for(var i:int = 0; i < n; i++){
					if(arr1[i] !== arr2[i]) return false;
				}
			}
			return true;
		}
		
	}
	
}