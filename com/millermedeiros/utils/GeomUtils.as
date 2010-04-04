/**
 * GeomUtils v0.4 (08/16/2009)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.utils {
	
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * GeomUtils
	 * @author Miller Medeiros (http://www.millermedeiros.com)
	 */
	public class GeomUtils {
		
		/// PI Number
		private static const PI:Number = Math.PI;
		/// Used to convert degree to radian (multiply to convert)
		private static const DEG_TO_RAD:Number = PI / 180;
		/// Used to convert radian to degree (multiply to convert)
		private static const RAD_TO_DEG:Number = 180 / PI;
		
		/**
		 * @private
		 */
		public function GeomUtils() {
			throw new Error("STATIC class and should NOT be instantiated.");
		}
		
		/**
		 * Reflect point around pivot (both axis)
		 * @param	p	Point to be reflected
		 * @param	pivot	Point used as a pivot
		 * @return	point reflection
		 */
		public static function reflectPoint(point:Point, pivot:Point):Point {
			var rx:Number = pivot.x - point.x;
			var ry:Number = pivot.y - point.y;
			return new Point(pivot.x + rx, pivot.y + ry);
		}
		
		/**
		 * Convert Degree to Radian
		 * @param	degree
		 * @return
		 */
		public static function degreeToRadians(degree:Number):Number {
			return degree * DEG_TO_RAD;
		}
		
		/**
		 * Convert Radian to Degree
		 * @param	radian
		 * @return
		 */
		public static function radianToDegree(radian:Number):Number {
			return radian * RAD_TO_DEG;
		}
		
		/**
		 * Draw Point to a Graphics Object
		 * @param	g	Graphics
		 * @param	p	Point
		 * @param	color	Hexadecimal color
		 * @param	size	Point size
		 */
		public static function plotPoint(g:Graphics, p:Point, color:uint = 0xFF0000, size:int = 2):void {
			g.beginFill(color);
			g.drawCircle(p.x, p.y , size);
			g.endFill();
		}
		
	}
	
}