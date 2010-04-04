/**
 * Copyright (c) 2010 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */

package com.millermedeiros.parsers {
	import com.millermedeiros.utils.ArrayUtils;
	
	/**
	 * Generic drawing commands to AS3 Graphics drawing commands
	 * @author Miller Medeiros
	 * @version 1.0 (2010/02/14)
	 */
	public class MotifsToAS3GraphicsCommands{
		
		private static var _prevFillStyle:Array = [];
		private static var _prevLineStyle:Array = [];
		private static var _prevCommand:String;
		
		/**
		 * @private
		 */
		public function MotifsToAS3GraphicsCommands() {
			throw new Error("This is a STATIC CLASS and should not be instantiated.");
		}
		
		/**
		 * Convert Motifs Array into AS3 Graphics drawing commands.
		 * @param	motifs	Motifs Array.
		 * @return	Drawing commands.
		 */
		public static function toCommandsString(motifs:Array):String{
			var commands:String = "";
			var n:int = motifs.length;
			
			/*
			_prevFillStyle = [0x000000, 1]; //default values
			_prevLineStyle = [NaN, 0, 1, false, "normal", "none", null, 3]; //default values
			*/
			
			commands += "/**\n";
			commands += "* Generated using Miller Medeiros (http://www.millermedeiros.com) SVG To Motifs Parser\n";
			commands += "*/\n";
			
			for(var i:int = 0; i < n; i++){
				switch(motifs[i][0]){
					case "B":
						if(! ArrayUtils.compare(motifs[i][1], _prevFillStyle)){
							commands += beginFill(motifs[i][1][0], motifs[i][1][1]);
							_prevFillStyle = motifs[i][1];
							commands += "\n";
						}
						break;
					case "C":
						commands += quadraticBezier(motifs[i][1][0], motifs[i][1][1], motifs[i][1][2], motifs[i][1][3]);
						commands += "\n";
						break;
					case "E":
						if(_prevCommand != 'E'){ //avoid duplicates
							commands += endFill();
							commands += "\n";
						}
						break;
					case "L":
						commands += lineTo(motifs[i][1][0], motifs[i][1][1]);
						commands += "\n";
						break;
					case "M":
						commands += moveTo(motifs[i][1][0], motifs[i][1][1]);
						commands += "\n";
						break;
					case "S":
						if (! ArrayUtils.compare(motifs[i][1], _prevLineStyle)){
							commands += lineStyle(motifs[i][1][0], motifs[i][1][1], motifs[i][1][2], motifs[i][1][3], motifs[i][1][4], motifs[i][1][5], motifs[i][1][6], motifs[i][1][7]);
							_prevLineStyle = motifs[i][1];
							commands += "\n";
						}
						break;
				}
				_prevCommand = motifs[i][0];
			}
			
			_prevFillStyle.length = 0; //faster than creating a new array
			_prevLineStyle.length = 0;
			
			return commands;
		}
		
		/**
		 * Convert "B" motif into a BEGIN FILL drawing command string.
		 * @param	color	Hexadecimal Fill Color
		 * @param	alpha	Alpha (opacity). Value range is from 0 to 1.
		 * @return	String that represent the BEGIN FILL command on the desired language/library.
		 */
		private static function beginFill(color:uint, alpha:Number = 1):String{
			return "graphics.beginFill(0x"+ color.toString(16).toUpperCase() +","+ alpha +");";
		}
		
		/**
		 * Convert "C" motif into a QUADRATIC BEZIER drawing command string.
		 * @param	cx	Control Point X position
		 * @param	cy	Control Point Y	position
		 * @param	px	End Point X	position
		 * @param	py	End Point Y	position
		 * @return	String that represent the QUADRATIC BEZIER command on the desired language/library.
		 */
		private static function quadraticBezier(cx:Number, cy:Number, px:Number, py:Number):String{
			var args:Array = arguments as Array;
			return "graphics.curveTo("+ args.join(',') +");";
		}
		
		/**
		 * Convert "E" motif into a END FILL drawing command string.
		 * @return	String that represent the END FILL command on the desired language/library.
		 */
		private static function endFill():String{
			return "graphics.endFill();";
		}
		
		/**
		 * Convert "L" motif into a LINE TO drawing command string.
		 * @param	x	End Point X position
		 * @param	y	End Point Y position
		 * @return	String that represent the LINE TO command on the desired language/library.
		 */
		private static function lineTo(x:Number, y:Number):String{
			var args:Array = arguments as Array;
			return "graphics.lineTo("+ args.join(',') +");";
		}
		
		/**
		 * Convert "M" motif into a MOVE TO drawing command string.
		 * @param	x	X position
		 * @param	y	Y position
		 * @return	String that represent the MOVE TO command on the desired language/library.
		 */
		public static function moveTo(x:Number, y:Number):String{
			var args:Array = arguments as Array;
			return "graphics.moveTo("+ args.join(',') +");";
		}
		
		/**
		 * Convert "L" motif into a SET LINE STYLE drawing command string.
		 * @param	thickness	Line thickness.
		 * @param	color	Hexadecimal line color.
		 * @param	alpha	Alpha (opacity). Value range is from 0 to 1.
		 * @param	pixelHinting	A Boolean value that specifies whether to hint strokes to full pixels.
		 * @param	scaleMode	The line scale mode.
		 * @param	caps	Specifies the type of caps at the end of lines.
		 * @param	joints	Type of joint appearance used at angles.
		 * @param	miterLimit	The limit at which a miter is cut off.
		 * @return	String that represents the SET LINE STYLE command on the desired language/library.
		 */
		private static function lineStyle(thickness:Number = NaN, color:uint = 0x000000, alpha:Number = 1, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = "none", joints:String = null, miterLimit:Number = 3):String{
			if(! isNaN(thickness)){
				var args:Array = arguments as Array;
				args[1] = "0x" + color.toString(16);
				args[4] = '"'+ scaleMode +'"';
				args[5] = (caps)? '"'+ caps +'"' : "null";
				args[6] = (joints)? '"' + joints +'"' : "null";
				return "graphics.lineStyle(" + args.join(',') +");";
			}else{
				return "graphics.lineStyle();";
			}
		}
		
	}

}