/**
 * QuadraticBezier v0.5 (2009/10/28)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.geom {
	
	import com.millermedeiros.utils.NumberUtils;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	//TODO: change getPoint() to use simple equation instead of baseLines
	
	/**
	 * The QuadraticBezier object represents a quadratic bezier curve
	 * @author Miller Medeiros (www.millermedeiros.com)
	 */
	public class QuadraticBezier {
		
		/// Control Point
		public var c:Point;
		/// Anchor Point 1
		public var p1:Point;
		/// Anchor Point 2
		public var p2:Point;
		
		/**
		 * Creates a new quadratic bezier curve
		 * @param	c	Control
		 * @param	p1	Anchor Point 1
		 * @param	p2	Anchor Point 2
		 */
		public function QuadraticBezier(c:Point, p1:Point, p2:Point) {
			this.c = c;
			this.p1 = p1;
			this.p2 = p2;
		}
		
		/**
		 * Draw curve to a Graphics object
		 * @param	g
		 */
		public function plot(g:Graphics, moveTo:Boolean = true, endFill:Boolean = false):void {
			if(moveTo) g.moveTo(p1.x, p1.y);
			g.curveTo(c.x, c.y, p2.x, p2.y);
			if (endFill) g.endFill();
		}
		
		/**
		 * Convert to a Motifs Array
		 * @return	Motif Array
		 */
		public function toMotifs(moveTo:Boolean = false, endFill:Boolean = false):Array {
			var motifs:Array = [];
			if(moveTo) motifs.push(['M', [limitPrecision(p1.x), limitPrecision(p1.y)]]);
			motifs.push(["C", [limitPrecision(c.x), limitPrecision(c.y), limitPrecision(p2.x), limitPrecision(p2.y)]]);
			if (endFill) motifs.push(['E']);
			return motifs;
		}
		
		/**
		 * Remove unecessary precision
		 * @private
		 */
		private static function limitPrecision(n:Number):Number{
			return NumberUtils.limitPrecision(n, 2);
		}
		
		/**
		 * Transform curve based on a Matrix
		 * @param	t	Transformation Matrix
		 * @return	Transformed QuadraticBezier
		 */
		public function transform(t:Matrix):QuadraticBezier {
			return new QuadraticBezier(t.transformPoint(c), t.transformPoint(p1), t.transformPoint(p2));
		}
		
		/**
		 * Get point according to position in Bezier Curve
		 * @param	q	Bezier Curve
		 * @param	ratio	Position of the point in the Bezier Curve (0 <= ratio <= 1)
		 * @return	Point in the Bezier Curve
		 */
		public static function getPoint(q:QuadraticBezier, ratio:Number):Point {
			if (ratio != 0 && ratio != 1) {
				return Line.getPoint(getSubLine(q, ratio), ratio);
			}else if (ratio) {
				return q.p2;
			}else {
				return q.p1;
			}
		}
		
		/**
		 * Get a segment of the bezier curve based on start and end positions
		 * - based on de Casteljau's algorithm: http://en.wikipedia.org/wiki/De_Casteljau%27s_algorithm
		 * @param	c	Bezier Curve
		 * @param	start	Start position (0<=start<=1)
		 * @param	end	End position (start<end<=1)
		 * @return	Segment of the Bezier Curve
		 */
		public static function segment(q:QuadraticBezier, start:Number = 0, end:Number = 1):QuadraticBezier {
			return new QuadraticBezier(Line.getPoint(getSubLine(q, start), end), getPoint(q, start), getPoint(q, end));;
		}
		
		/**
		 * Split Bezier curve into 2 Bezier Curves
		 * - based on de Casteljau's algorithm: http://en.wikipedia.org/wiki/De_Casteljau%27s_algorithm
		 * @param	q	Bezier Curve
		 * @param	ratio	Position of the bezier curve where the split should happen (0<ratio<1)
		 * @return	Array<QuadraticBezier> with 2 Quadratic Bezier Curves
		 */
		public static function split(q:QuadraticBezier, ratio:Number = .5):Array {
			return [ segment(q, 0, ratio), segment(q, ratio, 1) ];
		}
		
		/**
		 * Get lines connecting anchor and control points
		 * @param	q	Bezier Curve
		 * @return	Array<Line> with 2 Lines
		 */
		private static function getBaseLines(q:QuadraticBezier):Array {
			return [new Line(q.p1, q.c), new Line(q.c, q.p2)];
		}
		
		/**
		 * Get line connecting points of the base lines based on a specific ratio
		 * @param	q	Bezier Curve
		 * @param	ratio	Ratio applyed to each line
		 * @return	Line connecting base lines
		 */
		private static function getSubLine(q:QuadraticBezier, ratio:Number):Line {
			var baseLines:Array = getBaseLines(q);
			return new Line(Line.getPoint(baseLines[0], ratio), Line.getPoint(baseLines[1], ratio));
		}
		
		/**
		 * Creates a copy of the QuadraticBezier object
		 * @return	The new QuadraticBezier object
		 */
		public function clone():QuadraticBezier {
			return new QuadraticBezier(c, p1, p2);
		}
		
		/**
		 * Returns a string that contains the values of the x and y coordinates of the control point and anchor points.
		 * @return	Control and Anchor Points Coordinates
		 */
		public function toString():String {
			return "(c=" + c + ", p1=" + p1 + ", p2=" + p2+")";
		}
		
	}
	
}