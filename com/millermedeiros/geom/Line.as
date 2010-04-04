/**
 * Line v0.4 (2009/09/22)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.geom {
	
	import com.millermedeiros.utils.NumberUtils;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Object that represents a line segment
	 * @author Miller Medeiros (www.millermedeiros.com)
	 */
	public class Line {
		
		/// Start anchor point
		public var start:Point;
		/// End anchor point
		public var end:Point;
		
		/**
		 * Creates a new Line object
		 * @param	start	Start anchor point
		 * @param	end	End anchor point
		 */
		public function Line(start:Point, end:Point) {
			setPoints(start, end);
		}
		
		/**
		 * Shortcut to update points position
		 * @param	start	Begin anchor point
		 * @param	end	End anchor point
		 */
		public function setPoints(start:Point, end:Point):void {
			this.start = start;
			this.end = end;
		}
		
		/**
		 * Middle point of the line
		 */		
		public function get middle():Point {
			return getPoint(this, .5);
		}
		
		/**
		 * Length of the line
		 */
		public function get length():Number {
			return Point.distance(start, end);
		}
		
		/**
		 * Get point according to position in the line
		 * @param	line	Line
		 * @param	ratio	Position of the point in the line (0 <= ratio <= 1)
		 * @return	Point in the line
		 */
		public static function getPoint(line:Line, ratio:Number):Point {
			if (ratio != 0 && ratio != 1) {
				return new Point( line.start.x + ((line.end.x - line.start.x) * ratio), line.start.y + ((line.end.y - line.start.y) * ratio));
			} else if (ratio) {
				return line.end;
			}else {
				return line.start;
			}
		}
		
		/**
		 * Get a segment of the original Line
		 * @param	line	Base line
		 * @param	start	Start position (0<=start<=1)
		 * @param	end	End position (start<end<=1)
		 * @return	Segment of the Line
		 */
		public static function segment(line:Line, start:Number = 0, end:Number = 1):Line {
			return new Line(getPoint(line, start), getPoint(line, end));
		}
		
		/**
		 * Split line into 2 Lines
		 * @param	line	Base line
		 * @param	ratio	Position where the split should happen (0<ratio<1)
		 * @return	Array<Line> with 2 lines
		 */
		public static function split(line:Line, ratio:Number = .5):Array {
			return [ segment(line, 0, ratio), segment(line, ratio, 1) ];
		}
		
		/**
		 * Transform Line based on a Matrix
		 * @param	t	Tranformation Matrix
		 * @return Transformed Line
		 */
		public function transform(t:Matrix):Line {
			return new Line(t.transformPoint(start), t.transformPoint(end));
		}
		
		/**
		 * Draw line to a graphics object
		 * @param	g	Graphics object
		 * @param	moveTo	Add moveTo() command before drawing?
		 */
		public function plot(g:Graphics, moveTo:Boolean = true):void {
			if(moveTo) g.moveTo(start.x, start.y);
			g.lineTo(end.x, end.y);
		}
		
		/**
		 * Convert Line to Motifs Array
		 * @return	Motifs Array
		 */
		public function toMotifs(moveTo:Boolean = true):Array {
			var motifs:Array = [];
			if(moveTo) motifs.push(['M', [limitPrecision(start.x), limitPrecision(start.y)]]);
			motifs.push(['L', [limitPrecision(end.x), limitPrecision(end.y)]]);
			return motifs;
		}
		
		/**
		 * Remove unnecessary precision
		 */
		private static function limitPrecision(n:Number):Number{
			return NumberUtils.limitPrecision(n, 2);
		}
		
		/**
		 * Creates a copy of the Line object
		 * @return	The new Line object
		 */
		public function clone():Line {
			return new Line(start, end);
		}
		
		/**
		 * Returns a string that contains the values of the x and y coordinates of the anchor points.
		 * @return	Anchor Points Coordinates
		 */
		public function toString():String {
			return "(start=" + start + ", end=" + end + ")";
		}
		
	}
	
}