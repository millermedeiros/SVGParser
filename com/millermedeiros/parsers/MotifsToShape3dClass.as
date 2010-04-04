/**
 * Copyright (c) 2010 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */

package com.millermedeiros.parsers {
	
	/**
	 * Convert generic drawing commands to FIVe3D Shape3D Class
	 * @author Miller Medeiros
	 * @version 1.0 (2010/02/14)
	 */
	public class MotifsToShape3dClass{
		
		/**
		 * @private
		 */
		public function MotifsToShape3dClass() {
			throw new Error("This is a STATIC CLASS and should not be instantiated.");
		}
		
		/**
		 * Convert drawing commands into FIVe3D Shape3D Class.
		 * @param	motifs	Drawing commands array.
		 * @return	String of FIVe3D Shape3D Class
		 */
		public static function toClassString(motifs:Array, className:String = "MyAwesomeVector", packageName:String = ""):String{
			var output:String = "";
			
			output += "/**\n";
			output += "* Generated using Miller Medeiros (http://www.millermedeiros.com) SVG To Motifs Parser\n";
			output += "*/\n";
			//open package
			output += "package " + packageName +"{";
			output += "\n";
			output += "\t";
			
			//imports
			output += "import net.badimon.five3D.display.Shape3D;"
			output += "\n";
			output += "\t";
			
			//open class
			output += "public class " + className +" extends Shape3D{";
			output += "\n";
			output += "\t\t";
			
			//open constructor
			output += "public function " + className +"(){";
			output += "\n";
			output += "\t\t\t";
			output += "super();";
			output += "\n";
			output += "\t\t\t";
			output += "plotMotifs();"
			
			//close constructor
			output += "\n";
			output += "\t\t";
			output += "}"
			output += "\n";
			output += "\t\t";
			
			//open initMotifs()
			output += "private function plotMotifs():void{";
			output += "\n";
			output += "\t\t\t";
			output += "this.graphics3D.addMotif(" + MotifsParser.toMotifsString(motifs) +");";
			
			//close initMotifs()
			output += "\n";
			output += "\t\t";
			output += "}"
			
			//close  class
			output += "\n";
			output += "\t";
			output += "}"
			
			//close  package
			output += "\n";
			output += "}"
			
			return output;
		}
		
	}

}