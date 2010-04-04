/**
 * Copyright (c) 2010 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */

package com.millermedeiros.parsers {
	import com.millermedeiros.utils.ArrayUtils;
	
	/**
	 * Generic drawing commands to HTML5 Canvas drawing commands
	 * @author Miller Medeiros
	 * @version 1.0 (2010/02/14)
	 */
	public class MotifsToHTML5CanvasCommands{
		
		private static var _prevFillStyle:Array = [];
		private static var _prevLineStyle:Array = [];
		static private var _prevCommand:String;
		static private var _hasFill:Boolean;
		static private var _hasStroke:Boolean;
		
		
		/**
		 * @private
		 */
		public function MotifsToHTML5CanvasCommands() {
			throw new Error("This is a STATIC CLASS and should not be instantiated.");
		}
		
		/**
		 * Convert Motifs Array into HTML Canvas drawing commands.
		 * @param	motifs	Motifs Array.
		 * @return	Drawing commands.
		 */
		public static function toCommandsString(motifs:Array):String{
			var commands:String = "";
			var n:int = motifs.length;
			
			commands += "/**\n";
			commands += "* Generated using Miller Medeiros (http://www.millermedeiros.com) SVG To Motifs Parser\n";
			commands += "*/\n";
			
			/*
			_prevFillStyle = [0x000000, 1]; //default values
			_prevLineStyle = [NaN, 0, 1, false, "normal", "none", null, 3]; //default values
			*/
			
			for(var i:int = 0; i < n; i++){
				switch(motifs[i][0]){
					case "B":
						
						if(_prevCommand != 'E'){ //ensure that a new path will be created even without endFill command
							commands += endFill();
						}
						
						if(motifs[i][1].length){
							if(! ArrayUtils.compare(motifs[i][1], _prevFillStyle)){
								commands += beginFill(motifs[i][1][0], motifs[i][1][1]);
								_prevFillStyle = motifs[i][1];
								commands += "\n";
							}
							_hasFill = true;
						}else{
							_hasFill = false;
						}
						break;
						
					case "C":
						commands += quadraticBezier(motifs[i][1][0], motifs[i][1][1], motifs[i][1][2], motifs[i][1][3]);
						commands += "\n";
						break;
						
					case "E":
						if(_prevCommand != 'E' && _prevCommand != 'B' && _prevCommand != 'S'){ //the SVGToMotifs always start with BEGIN_FILL if path is filled followed by LINE_STYLE, if previous is B or S means that it is an empty path.
							commands += endFill();
						}
						break;
						
					case "L":
						commands += lineTo(motifs[i][1][0], motifs[i][1][1]);
						commands += "\n";
						break;
						
					case "M":
						if(_prevCommand == 'E'){
							_hasFill = false; //set as unfilled path (the SVGToMotifs always start with BEGIN_FILL if path is filled followed by LINE_STYLE)
						}
						commands += moveTo(motifs[i][1][0], motifs[i][1][1]);
						commands += "\n";
						break;
						
					case "S":
						
						if(_prevCommand == 'E'){
							_hasFill = false; //set as unfilled path (the SVGToMotifs always start with BEGIN_FILL if path is filled)
						}else if(_prevCommand != 'B'){ //ensure that a new path will be created even without endFill command
							commands += endFill();
						}
						
						if(motifs[i][1].length){
							if(! ArrayUtils.compare(motifs[i][1], _prevLineStyle)){
								commands += lineStyle(motifs[i][1][0], motifs[i][1][1], motifs[i][1][2], motifs[i][1][3], motifs[i][1][4], motifs[i][1][5], motifs[i][1][6], motifs[i][1][7]);
								_prevLineStyle = motifs[i][1];
								commands += "\n";
							}
							_hasStroke = true;
						}else{
							_hasStroke = false;
						}
						
						break;
				}
				_prevCommand = motifs[i][0];
			}
			
			// ensure last element is filled/stroked if last command isn't END_FILL
			if(_prevCommand != 'E'){
				commands += endFill();
			}
			
			//reset values
			_prevFillStyle.length = 0; //faster than creating a new Array
			_prevLineStyle.length = 0;
			_prevCommand = null;
			_hasFill = false;
			_hasStroke = false;
			
			return commands;
		}
		
		/**
		 * Convert "B" motif into a BEGIN FILL drawing command string.
		 * @param	color	Hexadecimal Fill Color
		 * @param	alpha	Alpha (opacity). Value range is from 0 to 1.
		 * @return	String that represent the BEGIN FILL command on the desired language/library.
		 */
		private static function beginFill(color:uint, alpha:Number = 1):String{
			var output:String = "";
			output += 'context.fillStyle = "';
			output += parseColor(color, alpha);
			output += '";';
			return output;
		}
		
		/**
		 * Convert color+alpha into RGBA (if alpha < 1) or HEX (if alpha == 0)
		 * @param	color	Color
		 * @param	alpha	Alpha
		 * @return	RGBA or Hex value
		 */
		private static function parseColor(color:uint, alpha:Number = 1):String{
			if(alpha < 1){
				return uintToRGBA(color, alpha);
			}else if(color){
				var hex:String = color.toString(16);
				if(hex.length < 6){
					hex = addZeroes(hex, 6 - hex.length);
				}
				return '#'+ hex;
			}else{
				return '#000000';
			}
		}
		
		/**
		 * Convert uint + alpha into CSS RGBA
		 * @param	color	Color
		 * @param	alpha	Alpha
		 * @return	CSS RGBA value
		 */
		private static function uintToRGBA(color:uint, alpha:Number = 1):String{
			var hex:String = color.toString(16);
			if (hex.length < 6){
				hex = addZeroes(hex, 6 - hex.length);
			}
			var channels:Array = hex.match(/[0-9a-fA-F]{2}/g);
			var r:int = parseInt(channels[0], 16);
			var g:int = parseInt(channels[1], 16);
			var b:int = parseInt(channels[2], 16);
			return 'rgba('+ r +', '+ g +', '+ b +', '+ alpha +')';
		}
		
		/**
		 * Add 'n' zeroes at the begining of the String
		 * @param	str	String
		 * @param	n	Number of Zeroes
		 * @return	n Zeroes + String
		 */
		private static function addZeroes(str:String, n:int):String{
			var output:String = "";
			while(n--){
				output += "0";
			}
			output += str;
			return output;
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
			return "context.quadraticCurveTo("+ args.join(',') +");";
		}
		
		/**
		 * Convert "E" motif into a END FILL drawing command string.
		 * @return	String that represent the END FILL command on the desired language/library.
		 */
		private static function endFill():String{
			var output:String = "";
			output += (_hasFill)? "context.fill();\n" : "";
			output += (_hasStroke)? "context.stroke();\n" : "";
			output += "context.beginPath();\n";
			_prevCommand = 'E'; // Set previous command as END_FILL to avoid duplicates
			return output;
		}
		
		/**
		 * Convert "L" motif into a LINE TO drawing command string.
		 * @param	x	End Point X position
		 * @param	y	End Point Y position
		 * @return	String that represent the LINE TO command on the desired language/library.
		 */
		private static function lineTo(x:Number, y:Number):String{
			var args:Array = arguments as Array;
			return "context.lineTo("+ args.join(',') +");";
		}
		
		/**
		 * Convert "M" motif into a MOVE TO drawing command string.
		 * @param	x	X position
		 * @param	y	Y position
		 * @return	String that represent the MOVE TO command on the desired language/library.
		 */
		public static function moveTo(x:Number, y:Number):String{
			var args:Array = arguments as Array;
			return "context.moveTo("+ args.join(',') +");";
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
			var output:String = "";
			
			if(thickness != _prevLineStyle[0] && !isNaN(thickness)){
				output += 'context.lineWidth = ' + thickness +';';
			}
			
			if(!isNaN(color) && !isNaN(alpha) && (color != _prevLineStyle[1] || alpha != _prevLineStyle[2])){
				output += (output != "")? "\n" : "";
				output += 'context.strokeStyle = "' + parseColor(color, alpha) +'";';
			}
			
			if (caps != _prevLineStyle[5] && (caps != "none" || _prevLineStyle[5] != "butt")){
				caps = (caps == "none" || !caps)? "butt" : caps; //convert value
				output += (output != "")? "\n" : "";
				output += 'context.lineCap = "' + caps +'"';
			}
			
			if (joints != _prevLineStyle[6]){
				joints = (! joints)? 'miter' : joints; //default value
				output += (output != "")? "\n" : "";
				output += 'context.lineJoin = "' + joints +'"';
			}
			
			if (miterLimit != _prevLineStyle[7] && !isNaN(miterLimit)){
				output += (output != "")? "\n" : "";
				output += 'context.miterLimit = ' + miterLimit;
			}
			
			
			return output;
		}
		
	}

}