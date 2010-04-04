package com.millermedeiros.utils {
	
	/**
	 * NumberUtils
	 * @author Miller Medeiros
	 * @version 0.2 (2009/10/28)
	 */
	public class NumberUtils {
		
		/**
		 * @private
		 */
		public function NumberUtils() {
			throw new Error("this is a STATIC class and shouldn't be instantiated.");
		}
		
		/**
		 * Limit Number precision
		 * - Ex: NumberUtils.limitPrecision(5.12345, 2) returns 5.12
		 * - Ex2: NumberUtils.limitPrecision(5.1, 2) returns 5.1
		 * @param	n	Number
		 * @param	maxPrecision	Maximum number of digits after dot
		 * @return	Number without any trailing zeroes and with a maximum number of decimal digits
		 */
		public static function limitPrecision(n:Number, maxPrecision:uint = 2):Number{
			return parseFloat(n.toFixed(maxPrecision));
		}
		
	}
	
}