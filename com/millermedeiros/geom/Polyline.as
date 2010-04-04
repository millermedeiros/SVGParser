/**
 * Polyline v0.3 (2009/09/22)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.geom {
	
	import com.millermedeiros.utils.NumberUtils;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Object that represents a set of connected straight line segments
	 * @author Miller Medeiros (www.millermedeiros.com)
	 */
	public class Polyline {
		
		/// Polyline points
		protected var _points:Array;
		
		/**
		 * Creates the Polyline object
		 * @param	pts<Point>	Points of the polyline
		 */
		public function Polyline(pts:Array) {
			points = pts;
		}
		
		/**
		 * Draw to a graphics object
		 * @param	g	Graphics object
		 */
		public function plot(g:Graphics, moveTo:Boolean = true):void {
			if(moveTo) g.moveTo(points[0].x, points[0].y);
			var tot:int = points.length;
			for (var i:int = 1; i < tot; i++) {
				g.lineTo(points[i].x, points[i].y);
			}
		}
		
		/**
		 * Convert to Motifs Array
		 * @return	Motifs Array
		 */
		public function toMotifs(moveTo:Boolean = true):Array {
			var motifs:Array = [];
			if(moveTo) motifs.push(['M', [limitPrecision(points[0].x), limitPrecision(points[0].y)]]);
			var tot:int = points.length;
			for (var i:int = 1; i < tot; i++) {
				motifs.push(['L', [limitPrecision(points[i].x), limitPrecision(points[i].y)]]);
			}
			return motifs;
		}
		
		/**
		 * Remove unecessary precision
		 */
		private static function limitPrecision(n:Number):Number{
			return NumberUtils.limitPrecision(n, 2);
		}
		
		/**
		 * Length of the Polyline
		 */
		public function get length():Number {
			var len:Number = 0;
			var tot:int = points.length - 1;
			for (var i:int = 0; i < tot; i++) {
				len += Point.distance(points[i], points[i + 1]);
			}
			return len;
		}
		
		/// Points
		public function get points():Array { return _points; }
		
		public function set points(value:Array):void {
			_points = value;
		}
		
		/**
		 * Add points
		 * @param	...pts<Point>	Points
		 */
		public function addPoints(...pts):void {
			points = points.concat(pts);
		}
		
		/**
		 * Transform Polyline based on a Matrix
		 * @param	matrix	Tranformation Matrix
		 * @return	Transformed Polyline
		 */
		public function transform(matrix:Matrix):* {
			var pts:Array = [];
			var n:int = points.length;
			while (n--) {
				pts[n] = matrix.transformPoint(points[n]);
			}
			return new Polyline(pts);
		}
		
		/**
		 * Creates a copy of the Polyline object
		 * @return	The new Polyline object
		 */
		public function clone():Polyline {
			return new Polyline(points);
		}
		
		/**
		 * Returns a string that contains the values of the x and y coordinates of the anchor points.
		 * @return	Anchor Points Coordinates
		 */
		public function toString():String {
			return String(points);
		}
		
	}
	
}