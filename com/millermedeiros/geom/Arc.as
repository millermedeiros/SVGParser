/**
 * Arc v0.1 (2009/09/28)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.geom {
	
	import com.millermedeiros.utils.GeomUtils;
	import com.millermedeiros.utils.NumberUtils;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	//TODO: add GETTERS and SETTERS to private properties
	
	/**
	 * Elliptical Arc object
	 * @author Miller Medeiros (http://www.millermedeiros.com/)
	 */
	public class Arc {
		
		protected var _cx:Number;
		protected var _cy:Number;
		protected var _rx:Number;
		protected var _ry:Number;
		protected var _rotation:Number;
		protected var _angleStart:Number;
		protected var _angleExtent:Number;
		
		public var matrix:Matrix;
		
		/**
		 * Create a new Elliptical Arc object
		 */
		public function Arc(cx:Number = 0, cy:Number = 0, rx:Number = 1, ry:Number = 1, rotation:Number = 0, angleStart:Number = 90, angleExtent:Number = 90) {
			this._cx = cx;
			this._cy = cy;
			this._rx = rx;
			this._ry = ry;
			this._rotation = rotation;
			this._angleStart = angleStart;
			this._angleExtent = angleExtent;
			this.matrix = new Matrix();
		}
		
		/**
		 * Get QuadraticBezier curves that construct the Arc
		 * @param	a	Arc
		 * @return	Array<QuadraticBezier> with QuadraticBezier curves
		 */
		public function getCurves():Array {
			
			var curves:Array = [];
			var base:Ellipse = getBaseEllipse();
			
			var nCurves:Number = Math.ceil(Math.abs(_angleExtent)/45);
			
			var theta:Number = GeomUtils.degreeToRadians(_angleExtent / nCurves);
			var curAngle:Number = GeomUtils.degreeToRadians(_angleStart);
			
			var cx:Number;
			var cy:Number;
			
			var c:Point;
			var p1:Point = base.getPointByRadianAngle(curAngle);
			var p2:Point;
			
			for(var i:int = 0; i<nCurves; i++){
				
				curAngle += theta;
				
				cx = _cx + Math.cos(curAngle-(theta *.5)) * (_rx / Math.cos(theta *.5));
				cy = _cy + Math.sin(curAngle-(theta *.5)) * (_ry / Math.cos(theta *.5));
				c = base.matrix.transformPoint(new Point(cx, cy));
				
				p2 = base.getPointByRadianAngle(curAngle);
				
				curves.push(new QuadraticBezier(c, p1, p2));
				p1 = p2;
				
			}
			
			return curves;
		}
		
		/**
		 * Get Ellipse that contains the Arc
		 * @return	Base Ellipse
		 */
		public function getBaseEllipse():Ellipse {
			var e:Ellipse = new Ellipse(_cx, _cy, _rx, _ry);
			e.rotation = _rotation;
			e.matrix.concat(matrix);
			return e;
		}
		
		/**
		 * Draw Arc to Graphics Object
		 * @param	g	Graphics Object
		 * @param	moveTo	If is a separate shape
		 * @param	endFill	If is a closed shape
		 */
		public function plot(g:Graphics, moveTo:Boolean = true, endFill:Boolean = false):void {
			var curves:Array = getCurves();
			var t:int = curves.length;
			for (var i:int = 0; i < t; i++) {
				curves[i].plot(g, (!i && moveTo));
			}
			if(endFill) g.endFill();
		}
		
		/**
		 * Convert Arc to drawing commands
		 * @param	moveTo	If is a separate shape
		 * @param	endFill	If is a closed shape
		 * @return	motifs Array
		 */
		public function toMotifs(moveTo:Boolean = true, endFill:Boolean = false):Array {
			var curves:Array = getCurves();
			var motifs:Array = [];
			var t:int = curves.length;
			for (var i:int = 0; i < t; i++) {
				motifs = motifs.concat(curves[i].toMotifs(!i && moveTo));
			}
			if (endFill) motifs.push(['E']);
			return motifs;
		}
		
		/**
		 * Conversion from center to endpoint parameterization
		 * - following: http://www.w3.org/TR/SVG/implnote.html#ArcConversionCenterToEndpoint
		 * @param	a Arc
		 * @return	Object containing parameters {start<Point>, end<Point>, rx<Number>, ry<Number>, rotation<Number>, isLarge<Boolean>, isClockwise<Boolean>}
		 */
		public static function toEndPoint(a:Arc):Object {
			
			//TODO: test toEndPoint conversion (not sure if it works)
			
			var radRotation:Number = GeomUtils.degreeToRadians(a._rotation);
			var radStart:Number = GeomUtils.degreeToRadians(a._angleStart);
			var radExtent:Number = GeomUtils.degreeToRadians(a._angleExtent);
			var sinRotation:Number = Math.sin(radRotation);
			var cosRotation:Number = Math.cos(radRotation);
			
			var start:Point = new Point();
			var rxcos:Number = a._rx * Math.cos(radStart);
			var rysin:Number = a._ry * Math.sin(radStart);
			start.x = (cosRotation * rxcos) + (-sinRotation * rxcos) + a._cx;
			start.y = (sinRotation * rysin) + (cosRotation * rysin) + a._cy;
			
			var end:Point = new Point();
			rxcos = a._rx * Math.cos(radStart + radExtent);
			rysin = a._ry * Math.sin(radStart + radExtent);
			end.x = (cosRotation * rxcos) + (-sinRotation * rxcos) + a._cx;
			end.y = (sinRotation * rysin) + (cosRotation * rysin) + a._cy;
			
			var isLarge:Boolean = (Math.abs(a._angleExtent) > 180);
			var isCounterClockwise:Boolean = (a._angleExtent > 0);
			
			return { start:start, end:end, rx:a._rx, ry:a._ry, rotation:a._rotation, isLarge:isLarge, isCounterClockwise:isCounterClockwise };
			
		}
		
		/**
		 * Remove unecessary precision
		 * @private
		 */
		private static function limitPrecision(n:Number):Number{
			return NumberUtils.limitPrecision(n, 2);
		}
		
		/**
		 * Clone Arc
		 */
		public function clone():Arc {
			var a:Arc = new Arc(_cx, _cy, _rx, _ry, _rotation, _angleStart, _angleExtent);
			a.matrix.concat(this.matrix);
			return a;
		}
		
		public function toString():String {
			return "(cx=" + _cx + ", cy=" + _cy +", rx=" + _rx + ", ry=" + _ry + ", rotation=" + _rotation +", angleStart=" + _angleStart +", angleExtent=" + _angleExtent +")";
		}
		
	}
	
}