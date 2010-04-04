/**
 * Ellipse v0.6 (2009/10/28)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.geom {
	
	import com.millermedeiros.utils.GeomUtils;
	import com.millermedeiros.utils.MatrixUtils;
	import com.millermedeiros.utils.NumberUtils;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	//TODO: add GETTERS to public vars (it's going to be completely wrong if the Ellipse has any kind of tranformation besides rotation)
	
	/**
	 * Ellipse object
	 * @author Miller Medeiros (http://www.millermedeiros.com/)
	 */
	public class Ellipse {
		
		private static const CONTROL_DISTANCE:Number = (4 * (Math.SQRT2 - 1)) / 3; // Used to find control points position (magic number)
		
		/// center X
		public var cx:Number;
		/// center Y
		public var cy:Number;
		/// radii X
		public var rx:Number;
		/// radii Y
		public var ry:Number;
		/// Transformation Matrix
		public var matrix:Matrix;
		
		/**
		 * Create Ellipse Object
		 * @param	cx	Center X position
		 * @param	cy	Center Y position
		 * @param	rx	X radii
		 * @param	ry	Y radii
		 */
		public function Ellipse(cx:Number, cy:Number, rx:Number, ry:Number) {
			this.cx = cx;
			this.cy = cy;
			this.rx = rx;
			this.ry = ry;
			this.matrix = new Matrix();
		}
		
		/**
		 * Compute bezier curves based on ellipse properties
		 * @return Array with 4 CubicBezier curves
		 */
		public function getCurves():Array{
			
			var top:Number = cy - ry;
			var left:Number = cx - rx;
			var right:Number = cx + rx;
			var bottom:Number = cy + ry;
			var dx:Number = rx * CONTROL_DISTANCE;
			var dy:Number = ry * CONTROL_DISTANCE;
			
			var curves:Array = []; // Bezier curves (counter-clockwise starting at 3h => 0º)
			curves[0] = new CubicBezier(new Point(right, cy - dy), new Point(cx + dx, top), new Point(right, cy), new Point(cx, top));
			curves[1] = new CubicBezier(new Point(cx - dx, top), new Point(left, cy - dy), new Point(cx, top), new Point(left, cy));
			curves[2] = new CubicBezier(new Point(left, cy + dy), new Point(cx - dx, bottom), new Point(left, cy), new Point(cx, bottom));
			curves[3] = new CubicBezier(new Point(cx + dx, bottom), new Point(right, cy + dy), new Point(cx, bottom), new Point(right, cy));
			
			return curves;
			
		}
		
		/**
		 * Transform based on a transformation Matrix (cumulative with previous transformations)
		 * obs: for non-cumulative effect use public property 'matrix' instead
		 * @param	transformMatrix
		 */
		public function transform(transformMatrix:Matrix):Ellipse {
			var e:Ellipse = clone();
			e.matrix.concat(transformMatrix);
			return e;
		}
		
		/**
		 * Draw to a graphics object
		 * @param	g	Graphics object
		 */
		public function plot(g:Graphics, moveTo:Boolean = true, endFill:Boolean = true):void {
			var curves:Array = getCurves();
			for(var i:int = 0; i < 4; i++) {
				curves[i].transform(matrix).plot(g, (!i && moveTo));
			}
			if (endFill) g.endFill();
		}
		
		/**
		 * Convert to Motifs Array
		 * @return	Motifs Array
		 */
		public function toMotifs(moveTo:Boolean = true, endFill:Boolean = true):Array {
			var curves:Array = getCurves();
			var motifs:Array = [];
			var c:CubicBezier;
			for (var i:int = 0; i < 4; i++) {
				c = curves[i].transform(matrix);
				motifs = motifs.concat(c.toMotifs(!i && moveTo));
			}
			if (endFill) motifs.push(['E']);
			return motifs;
		}
		
		/**
		 * Remove unnecessary precision
		 * @private
		 */
		private static function limitPrecision(n:Number):Number{
			return NumberUtils.limitPrecision(n, 2);
		}
		
		/**
		 * Get point based on position
		 * @param	ratio	Position of the point on the Ellipse (0 <= ratio <= 1)
		 * @return	Point in the Ellipse
		 */
		public function getPoint(ratio:Number):Point {
			return getPointByRadianAngle(ratio * Math.PI * 2);
		}
		
		/**
		 * Get Point based on Angle
		 * @param	angle	Angle in degrees
		 * @return	Point in the Ellipse
		 */
		public function getPointByAngle(angle:Number):Point {
			return getPointByRadianAngle(GeomUtils.degreeToRadians(angle));
		}
		
		/**
		 * Get Point based on Radian Angle
		 * @param	radAngle	Angle in radian
		 * @return	Point in the Ellipse
		 */
		public function getPointByRadianAngle(radAngle:Number):Point {
			var px:Number = cx + Math.cos(radAngle) * rx;
			var py:Number = cy + Math.sin(radAngle) * ry;
			return this.matrix.transformPoint(new Point(px, py));
		}
		
		/**
		 * Return a new Ellipse
		 * @return
		 */
		public function clone():Ellipse {
			var e:Ellipse = new Ellipse(cx, cy, rx, ry);
			e.matrix.concat(matrix);
			return e;
		}
		
		/// Rotate around center
		public function get rotation():Number { return MatrixUtils.getRotation(matrix); }
		
		public function set rotation(value:Number):void {
			value -= rotation;
			matrix = MatrixUtils.rotateAroundInternalPoint(matrix, new Point(cx, cy), value);
		}
		
		public function toString():String {
			return "(cx=" + cx + ", cy="+ cy +", rx=" + rx + ", ry=" + ry+")";
		}
		
	}
	
}