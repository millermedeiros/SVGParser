/**
 * Rect v0.1 (2009/09/22)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.geom {
	
	import com.millermedeiros.utils.NumberUtils;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Rectangle/RoundedRectangle object
	 * @author Miller Medeiros (http://www.millermedeiros.com/)
	 */
	public class Rect {
		
		private static const CONTROL_DISTANCE:Number = (4 * (Math.SQRT2 - 1)) / 3; // Used to find control points position
		
		private var _x:Number;
		private var _y:Number;
		private var _wid:Number;
		private var _hei:Number;
		private var _rx:Number;
		private var _ry:Number;
		
		/// Base items of the rectangle (Lines and CubicBezier)
		private var _base:Array;
		
		/// Transformation Matrix
		public var matrix:Matrix;
		
		/**
		 * Creates a Rectangle/RoundedRectangle object
		 * @param	x	X position
		 * @param	y	Y position
		 * @param	wid	Width
		 * @param	hei	Height
		 * @param	rx	radii X
		 * @param	ry	radii Y
		 */
		public function Rect(x:Number, y:Number, wid:Number, hei:Number, rx:Number = 0, ry:Number = 0) {
			_x = x;
			_y = y;
			_wid = wid;
			_hei = hei;
			_rx = (rx < wid*.5)? rx : wid*.5;
			_ry = (ry < hei * .5)? ry : hei * .5;
			// temp vars
			var right:Number = x + wid;
			var bottom:Number = y + hei;
			var lineX1:Number = x + _rx;
			var lineX2:Number = right - _rx;
			var lineY1:Number = y + _ry;
			var lineY2:Number = bottom - _ry;
			//lines
			_base = [];
			_base[0] = new Line(new Point(lineX1, y), new Point(lineX2, y));
			_base[1] = new Line(new Point(right, lineY1), new Point(right, lineY2));
			_base[2] = new Line(new Point(lineX2, bottom), new Point(lineX1, bottom));
			_base[3] = new Line(new Point(x, lineY2), new Point(x, lineY1));
			//curves
			if (_rx || _ry) {
				var dx:Number = _rx * CONTROL_DISTANCE;
				var dy:Number = _ry * CONTROL_DISTANCE;
				var c1:CubicBezier = new CubicBezier(new Point(lineX2 + dx, y), new Point(right, lineY1 - dy), new Point(lineX2, y), new Point(right, lineY1));
				var c2:CubicBezier = new CubicBezier(new Point(right, lineY2 + dy), new Point(lineX2 + dx, bottom), new Point(right, lineY2), new Point(lineX2, bottom));
				var c3:CubicBezier = new CubicBezier(new Point(lineX1 - dx, bottom), new Point(x, lineY2+dy), new Point(lineX1, bottom), new Point(x, lineY2));
				var c4:CubicBezier = new CubicBezier(new Point(x, lineY1-dy), new Point(lineX1-dx, y), new Point(x, lineY1), new Point(lineX1, y));
				_base.splice(1, 0, c1);
				_base.splice(3, 0, c2);
				_base.splice(5, 0, c3);
				_base.splice(7, 0, c4);
			}
			matrix = new Matrix();
		}
		
		/**
		 * Transform based on transform Matrix
		 * @param	transformMatrix
		 */
		public function transform(transformMatrix:Matrix):Rect {
			var r:Rect = clone();
			r.matrix.concat(transformMatrix);
			return r;
		}
		
		/**
		 * Draw to a graphics object
		 * @param	g	Graphics object
		 */
		public function plot(g:Graphics, moveTo:Boolean = true):void {
			if(moveTo){
				var init:Point = matrix.transformPoint(new Point(_x + _rx, _y));
				g.moveTo(init.x, init.y);
			}
			var t:int = _base.length;
			for (var i:int = 0; i < t; i++) {
				_base[i].transform(matrix).plot(g, false);
			}
		}
		
		/**
		 * Convert to Motifs Array
		 * @return	Motifs Array
		 */
		public function toMotifs(moveTo:Boolean = true):Array {
			var motifs:Array = [];
			if(moveTo){
				var init:Point = matrix.transformPoint(new Point(_x + _rx, _y));
				motifs.push(['M', [limitPrecision(init.x), limitPrecision(init.y)]]);
			}
			var t:int = _base.length;
			for (var i:int = 0; i < t; i++) {
				motifs = motifs.concat(_base[i].transform(matrix).toMotifs(false));
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
		 * Clone Rect
		 */
		public function clone():Rect {
			return new Rect(_x, _y, _wid, _hei, _rx, _ry);
		}
		
	}
	
}