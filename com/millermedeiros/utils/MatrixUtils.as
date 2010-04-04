/**
 * MatrixUtils v0.1 (09/08/2009)
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
package com.millermedeiros.utils {
	
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Usefull Functions for Matrix Transformations
	 * - Based on fl.motion.MatrixTransformer
	 * @author Miller Medeiros (http://www.millermedeiros.com/)
	 */
	public class MatrixUtils {
		
		/**
		 * @private
		 */
		public function MatrixUtils() {
			throw new Error("This is a STATIC class and should not be instantiated.");
		}
		
		public static function getScaleX(m:Matrix):Number{
			return Math.sqrt(m.a*m.a + m.b*m.b);
		}
		
		public static function setScaleX(m:Matrix, value:Number):Matrix{
			var mat:Matrix = m.clone();
			var sx:Number = getScaleX(mat);
			if (sx){
				var ratio:Number = value / sx;
				mat.a *= ratio;
				mat.b *= ratio;
			}else{
				var skewYRad:Number = getSkewYRadians(mat);
				mat.a = Math.cos(skewYRad) * value;
				mat.b = Math.sin(skewYRad) * value;
			}
			return mat;
		}
		
		public static function getScaleY(m:Matrix):Number{
			return Math.sqrt(m.c*m.c + m.d*m.d);
		}
		
		public static function setScaleY(m:Matrix, value:Number):Matrix{
			var mat:Matrix = m.clone();
			var sy:Number = getScaleY(mat);
			if (sy){
				var ratio:Number = value / sy;
				mat.c *= ratio;
				mat.d *= ratio;
			}else{
				var skewXRad:Number = getSkewXRadians(mat);
				mat.c = -Math.sin(skewXRad) * value;
				mat.d = Math.cos(skewXRad) * value;
			}
			return mat;
		}
		
		public static function getSkewXRadians(m:Matrix):Number{
			return Math.atan2(-m.c, m.d);
		}
		
		public static function setSkewXRadians(m:Matrix, value:Number):Matrix{
			var mat:Matrix = m.clone();
			var sy:Number = getScaleY(mat);
			mat.c = -sy * Math.sin(value);
			mat.d = sy * Math.cos(value);
			return mat;
		}
		
		public static function getSkewYRadians(m:Matrix):Number{
			return Math.atan2(m.b, m.a);
		}
		
		public static function setSkewYRadians(m:Matrix, value:Number):Matrix{
			var mat:Matrix = m.clone();
			var sx:Number = getScaleX(mat);
			mat.a = sx * Math.cos(value);
			mat.b = sx * Math.sin(value);
			return mat;
		}
		
		public static function getSkewX(m:Matrix):Number{
			return GeomUtils.radianToDegree(Math.atan2(-m.c, m.d));
		}
		
		public static function setSkewX(m:Matrix, value:Number):Matrix{
			return setSkewXRadians(m, GeomUtils.degreeToRadians(value));
		}
		
		public static function getSkewY(m:Matrix):Number{
			return GeomUtils.radianToDegree(Math.atan2(m.b, m.a));
		}
		
		public static function setSkewY(m:Matrix, value:Number):Matrix{
			return setSkewYRadians(m, GeomUtils.degreeToRadians(value));
		}
		
		public static function getRotationRadians(m:Matrix):Number{
			return getSkewYRadians(m);
		}
		
		public static function setRotationRadians(m:Matrix, value:Number):Matrix{
			var curRotation:Number = getRotationRadians(m);
			var curSkewX:Number = getSkewXRadians(m);
			var mat:Matrix = setSkewXRadians(m, curSkewX + value-curRotation);
			return setSkewYRadians(mat, value);
		}
		
		public static function getRotation(m:Matrix):Number{
			return GeomUtils.radianToDegree(getRotationRadians(m));
		}
		
		public static function setRotation(m:Matrix, value:Number):Matrix{
			return setRotationRadians(m, GeomUtils.degreeToRadians(value));
		}
		
		public static function rotateAroundInternalPoint(m:Matrix, pivot:Point, angleDegrees:Number):Matrix{
			pivot = m.transformPoint(pivot);
			return rotateAroundExternalPoint(m, pivot, angleDegrees);
		}
		
		public static function rotateAroundExternalPoint(m:Matrix, pivot:Point, angleDegrees:Number):Matrix{
			var mat:Matrix = m.clone();
			mat.tx -= pivot.x;
			mat.ty -= pivot.y;
			mat.rotate(GeomUtils.degreeToRadians(angleDegrees));
			mat.tx += pivot.x;
			mat.ty += pivot.y;
			return mat;
		}
		
		public static function matchInternalPointWithExternal(m:Matrix, internalPoint:Point, externalPoint:Point):Matrix{
			var mat:Matrix = m.clone();
			var p:Point = mat.transformPoint(internalPoint);
			var dx:Number = externalPoint.x - p.x;
			var dy:Number = externalPoint.y - p.y;	
			mat.tx += dx;
			mat.ty += dy;
			return mat;
		}
		
	}
	
}