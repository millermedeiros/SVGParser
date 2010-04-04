/**
 * CubicBezier v0.4 (2009/09/22)
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
	 * The CubicBezier object represents a cubic bezier curve
	 * @author Miller Medeiros (www.millermedeiros.com)
	 */
	public class CubicBezier {
		
		/// Control Point 1
		public var c1:Point;
		/// Control Point 2
		public var c2:Point;
		/// Anchor Point 1
		public var p1:Point;
		/// Anchor Point 2
		public var p2:Point;
		
		/**
		 * Creates a new cubic bezier curve
		 * @param	c1	Control Point 1
		 * @param	c2	Control Point 2
		 * @param	p1	Anchor Point 1
		 * @param	p2	Anchor Point 2
		 */
		public function CubicBezier(c1:Point, c2:Point, p1:Point, p2:Point) {
			setPoints(c1, c2, p1, p2);
		}
		
		/**
		 * Shortcut to update points position
		 * @param	c1	Control 1
		 * @param	c2	Control 2
		 * @param	p1	Anchor 1
		 * @param	p2	Anchor 2
		 */
		public function setPoints(c1:Point, c2:Point, p1:Point, p2:Point):void {
			this.c1 = c1;
			this.c2 = c2;
			this.p1 = p1;
			this.p2 = p2;
		}
		
		/**
		 * Converts a CubicBezier to 4 QuadraticBezier
		 * based on Timothée Groleau Fixed MidPoint approach - http://timotheegroleau.com/Flash/articles/cubic_bezier_in_flash.htm
		 * @param	c	CubicBezier to be converted
		 * @return	Array<QuadraticBezier> that contains 4 quadratic bezier curves
		 */
		public static function toQuadratics(c:CubicBezier):Array {
			var quads:Array = [];
			var anchors:Array = [];
			var controls:Array = [];
			var baseLines:Array = getBaseLines(c);
			var subLines:Array = getSubLines(c, .5);
			
			anchors[0] = baseLines[0].start;
			anchors[1] = subLines[3].middle;
			anchors[2] = subLines[2].middle;
			anchors[3] = subLines[4].middle;
			anchors[4] = baseLines[2].end;
			
			controls[0] = subLines[3].start;
			controls[1] = Line.getPoint(subLines[2], .125);
			controls[2] = Line.getPoint(subLines[2], .875);
			controls[3] = Line.getPoint(baseLines[2], .625);
			
			var n:int = 4;
			while (n--) {
				quads[n] = new QuadraticBezier(controls[n], anchors[n], anchors[n+1]);
			}
			return quads;
		}
		
		/**
		 * Draw curve to a Graphics object
		 * @param	g	Graphics object
		 */
		public function plot(g:Graphics, moveTo:Boolean = true):void {
			var quads:Array = toQuadratics(this);
			if(moveTo) g.moveTo(quads[0].p1.x, quads[0].p1.y);
			var n:int = quads.length;
			for(var i:int = 0; i < n; i++) {
				quads[i].plot(g, false);
			}
		}
		
		/**
		 * Convert to Motifs Array
		 * @return	Motifs Array
		 */
		public function toMotifs(moveTo:Boolean = false):Array {
			var motifs:Array = [];
			if(moveTo) motifs.push(['M', [limitPrecision(p1.x), limitPrecision(p1.y)]]);
			var quads:Array = toQuadratics(this);
			var n:int = quads.length;
			for (var i:int = 0; i < n; i++) {
				motifs = motifs.concat(quads[i].toMotifs());
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
		 * Transform curve based on a Matrix
		 * @param	t	Transformation Matrix
		 * @return	Transformed bezier curve
		 */
		public function transform(t:Matrix):CubicBezier {
			return new CubicBezier(t.transformPoint(c1), t.transformPoint(c2), t.transformPoint(p1), t.transformPoint(p2));
		}
		
		/**
		 * Get point according to position in Bezier Curve
		 * @param	q	Bezier Curve
		 * @param	ratio	Position of the point in the Bezier Curve (0 <= ratio <= 1)
		 * @return	Point in the Bezier Curve
		 */
		public static function getPoint(c:CubicBezier, ratio:Number):Point {
			if (ratio != 0 && ratio != 1) {
				return Line.getPoint(getSubLines(c, ratio)[2], ratio);
			}else if (ratio) {
				return c.p2;
			}else {
				return c.p1;
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
		public static function segment(c:CubicBezier, start:Number = 0, end:Number = 1):CubicBezier {
			return new CubicBezier(Line.getPoint(getSubLines(c, start)[2], end), Line.getPoint(getSubLines(c, end)[2], start), getPoint(c, start), getPoint(c, end));
		}
		
		/**
		 * Split Bezier curve into 2 Cubic Bezier Curves
		 * - based on de Casteljau's algorithm: http://en.wikipedia.org/wiki/De_Casteljau%27s_algorithm
		 * @param	c	Bezier Curve
		 * @param	ratio	Position of the bezier curve where the split should happen (0<ratio<1)
		 * @return	Array<CubicBezier> with 2 Cubic Bezier Curves
		 */
		public static function split(c:CubicBezier, ratio:Number = .5):Array {
			return [ segment(c, 0, ratio), segment(c, ratio, 1) ];
		}
		
		/**
		 * Get lines connecting all anchor points and control points
		 * starting from the p1 and ending at p2
		 * @param	c	Bezier Curve
		 * @return	Array<Line> with 3 lines
		 */
		private static function getBaseLines(c:CubicBezier):Array {
			return [ new Line(c.p1, c.c1), new Line(c.c1, c.c2), new Line(c.c2, c.p2) ];
		}
		
		/**
		 * Get lines connecting points of the base lines based on a specific ratio
		 * @param	c	Bezier Curve
		 * @param	ratio	Ratio applyed to each line
		 * @return	Array<Line> with 5 lines (lines 4 and 5 used to transform cubic to quadratics)
		 */
		private static function getSubLines(c:CubicBezier, ratio:Number):Array {
			var subLines:Array = [];
			var baseLines:Array = getBaseLines(c);
			subLines[0] = new Line(Line.getPoint(baseLines[0], ratio), Line.getPoint(baseLines[1], ratio));
			subLines[1] = new Line(Line.getPoint(baseLines[1], ratio), Line.getPoint(baseLines[2], ratio));
			subLines[2] = new Line(Line.getPoint(subLines[0], ratio), Line.getPoint(subLines[1], ratio));
			subLines[3] = new Line(Line.getPoint(baseLines[0], .375), Line.getPoint(subLines[2], .125));
			subLines[4] = new Line(Line.getPoint(baseLines[2], .625), Line.getPoint(subLines[2], .875));
			return subLines;
		}
		
		/**
		 * Creates a copy of the CubicBezier object
		 * @return	The new CubicBezier object
		 */
		public function clone():CubicBezier {
			return new CubicBezier(c1, c2, p1, p2);
		}
		
		/**
		 * Returns a string that contains the values of the x and y coordinates of the control points and anchor points.
		 * @return	Controls and Anchor Points Coordinates
		 */
		public function toString():String {
			return "(c1=" + c1 + ", c2="+ c2 +", p1=" + p1 + ", p2=" + p2+")";
		}
		
	}
	
}