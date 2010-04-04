/**
 * Copyright (c) 2010 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */

package com.millermedeiros.geom {
	
	import com.millermedeiros.utils.GeomUtils;
	import flash.geom.Point;
	
	/**
	 * SVGArc Implementation following: http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
	 * @author Miller Medeiros (http://www.millermedeiros.com/)
	 * @version 1.0 (2010/02/13)
	 */
	public class SVGArc extends Arc {
		
		/**
		 * Create a new SVG Elliptical Arc object
		 * - Conversion from endpoint to center parameterization following: http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
		 * @param	start	Start Point
		 * @param	end	End Point
		 * @param	rx	X radii of the ellipse
		 * @param	ry	Y radii of the ellipse
		 * @param	rotation Rotation angle of the ellipse (in degrees)
		 * @param	isLarge	Define if is a large arc (large-arc-flag)
		 * @param	isCounterClockwise	Define if arc should be draw clockwise (sweep-flag)
		 */
		public function SVGArc(start:Point, end:Point, rx:Number, ry:Number, rotation:Number = 0, isLarge:Boolean = false, isCounterClockwise:Boolean = false){
			super();
			
			//midpoint
			var midX:Number = (start.x - end.x) / 2;
			var midY:Number = (start.y - end.y) / 2;
			
			//rotation
			_rotation = rotation;
			var radRotation:Number = GeomUtils.degreeToRadians(rotation);
			var sinRotation:Number = Math.sin(radRotation);
			var cosRotation:Number = Math.cos(radRotation);
			
			//(x1', y1')
			var x1:Number = cosRotation * midX + sinRotation * midY;
	        var y1:Number = -sinRotation * midX + cosRotation * midY;
			
			// Correction of out-of-range radii
			if (rx == 0 || ry == 0) throw new Error("rx and rx can't be equal to zero !!"); // Ensure radii are non-zero
			_rx = Math.abs(rx);
			_ry = Math.abs(ry);
			var x1_2:Number = x1 * x1;
			var y1_2:Number = y1 * y1;
			var rx_2:Number = _rx * _rx;
			var ry_2:Number = _ry * _ry;
			var radiiFix:Number = (x1_2 / rx_2) + (y1_2 / ry_2);
			if(radiiFix > 1){
				_rx = Math.sqrt(radiiFix) * _rx;
				_ry = Math.sqrt(radiiFix) * _ry;
				rx_2 = _rx * _rx;
				ry_2 = _ry * _ry;
			}
			
			//(cx', cy')
			var cf:Number = ((rx_2 * ry_2) - (rx_2 * y1_2) - (ry_2 * x1_2)) / ((rx_2 * y1_2) + (ry_2 * x1_2));
			cf = (cf > 0)? cf : 0;
			var sqr:Number = Math.sqrt(cf);
			sqr *= (isLarge != isCounterClockwise)? 1 : -1;
			var cx1:Number = sqr * ((_rx * y1) / _ry);
			var cy1:Number = sqr * -((_ry * x1) / _rx);
			
			//(cx, cy) from (cx', cy')
			_cx = (cosRotation * cx1 - sinRotation * cy1) + ((start.x + end.x) / 2);
			_cy = (sinRotation * cx1 + cosRotation * cy1) + ((start.y + end.y) / 2);
			
			// angleStart and angleExtent
			var ux:Number = (x1 - cx1) / _rx;
	        var uy:Number = (y1 - cy1) / _ry;
	        var vx:Number = (-x1 - cx1) / _rx;
	        var vy:Number = (-y1 - cy1) / _ry;
			var uv:Number = ux*vx + uy*vy; // u.v
			var u_norm:Number = Math.sqrt(ux*ux + uy*uy); // ||u||
			var uv_norm:Number = Math.sqrt((ux*ux + uy*uy) * (vx*vx + vy*vy)); // ||u||||v||
			var sign:int;
			sign = (uy < 0)? -1 : 1; //((1,0),(vx, vy))
			_angleStart = GeomUtils.radianToDegree( sign * Math.acos(ux / u_norm) );
			sign = ((ux*vy - uy*vx) < 0)? -1 : 1; //((ux,uy),(vx, vy))
			_angleExtent = GeomUtils.radianToDegree( sign * Math.acos(uv / uv_norm));
			if (!isCounterClockwise && _angleExtent > 0) _angleExtent -= 360;
			else if (isCounterClockwise && _angleExtent < 0) _angleExtent += 360;
			_angleStart %= 360;
			_angleExtent %= 360;
			
		}
		
	}

}