/**
 * Copyright (c) 2010 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */

package com.millermedeiros.parsers{
	
	import flash.display.Graphics;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * Convert Motifs into String
	 * @author Miller Medeiros
	 * @version 0.1 (2010/02/13)
	 */
	public class MotifsParser{
		
		/**
		 * Static Class
		 * @private
		 */
		public function MotifsParser(){
			throw new Error("This is a STATIC CLASS and should not be instantiated.");
		}
		
		/**
		 * Convert a motifs Array into a String
		 * - copyed from com.millermedeiros.utils.ArrayUtils.toStringArray();
		 * @param	motifs	Motifs Array (drawing commands)
		 * @return	String that represents all drawing commands.
		 */
		public static function toMotifsString(motifs:Array):String{
			var str:String = "[";
			function checkType(item:*, index:int, array:Array):void{
				str += (!index)? '' : ',';
				switch(getQualifiedClassName(item)){
					case "Array":
						str += "[";
						item.forEach(checkType);
						str += "]";
						break;
					case "Object":
						str += "{";
						for(var prop:String in item){
							str += prop + ":";
							checkType(item[prop], 0, []);
							str += ",";
						}
						str = str.substr(0, str.length - 1) + "}";
						break;
					case "String":
						str += "'" + item + "'";
						break;
					case "void":
						break;
					default:
						str += item;
				}	
			}
			motifs.forEach(checkType);
			return str + "]";
		}
		
		/**
		 * Draw motifs into a Graphics Object.
		 * - based on Mathieu Badimon Five3d Graphics3D.draw() method (http://five3d.mathieu-badimon.com/).
		 * @param	g	Graphics target
		 * @param	motifs	Motifs Array
		 */
		public static function plot(g:Graphics, motifs:Array):void{
			var n:int = motifs.length;
			for(var i:int = 0; i < n; i++){
				switch(motifs[i][0]){
					case "B":
						g.beginFill(motifs[i][1][0], motifs[i][1][1]);
						break;
					case "C":
						g.curveTo(motifs[i][1][0], motifs[i][1][1], motifs[i][1][2], motifs[i][1][3]);
						break;
					case "E":
						g.endFill();
						break;
					case "L":
						g.lineTo(motifs[i][1][0], motifs[i][1][1]);
						break;
					case "M":
						g.moveTo(motifs[i][1][0], motifs[i][1][1]);
						break;
					case "S":
						g.lineStyle(motifs[i][1][0], motifs[i][1][1], motifs[i][1][2], motifs[i][1][3], motifs[i][1][4], motifs[i][1][5], motifs[i][1][6], motifs[i][1][7]);
						break;
				}
			}
		}
		
	}

}