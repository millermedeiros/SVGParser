package com.millermedeiros.utils {
	
	/**
	 * StringUtils - Useful functions for string formating
	 * @author Miller Medeiros (http://www.millermedeiros.com)
	 * @version	0.5.2 (2010/02/09)
	 */
	public class StringUtils {
		
		/**
		 * @private
		 */
		public function StringUtils() {
			throw new Error("This is a STATIC class and should not be instantiated.");
		}
		
		/**
		 * Returns the formated deep-linking path
		 * - ex: StringUtils.toPathFormat("Lorem","Ipsum dolor")  returns   "/lorem/ipsum-dolor/"
		 */
		public static function toPathFormat(...rest):String {
			
			var path:String = "/";
			
			// adds a "/" after each path name and remove non word chars
			for (var i:int = 0; i < rest.length; i++) {
				path += (rest[i])? removeNonWordChars(rest[i]) + "/" : "";
			}
			
			path = replaceAccents(path);
			path = removeMultipleSpaces(path);
			path = path.toLowerCase().replace(/\s/g, "-"); // converts to lowercase and replaces all " " to "-"
			
			return path;
			
		}
		
		/**
		 * Format page title based on path (based on SEO standard)
		 * - ex: StringUtils.toTitleFormat("/lorem/ipsum-dolor/", "Default Page Title") returns "Ipsum Dolor | Lorem | Default Page Title"
		 * @param	path	Url path (ex: "/lorem/ipsum-dolor/")
		 * @param	defaultTitle	Default Page Title
		 * @param	separator	Char used to separate path names
		 * @return	Formated String
		 */
		public static function toTitleFormat(path:String, defaultTitle:String = "", separator:String = " | "):String {
			
			// Remove empty items of the pathsArr
			function isNotEmpty(item:*, index:int, array:Array):Boolean {
				return (item.length > 0);
			}
			
			var pathsArr:Array = path.split("/").filter(isNotEmpty);
			
			// Adds each path to the title (last path comes first)
			for (var i:int = 0; i < pathsArr.length; i++) {
				defaultTitle = pathsArr[i] + separator + defaultTitle;
			}
			
			defaultTitle =  defaultTitle.replace(/\-/g, " ").replace(/\_/g, " "); // Replaces "-" and "_" to " "
			return toProperCase(defaultTitle);
			
		}
		
		/**
		 * Convert first char of each word to upper case
		 * - ex: StringUtils.toProperCase("lorem ipsum dolor") returns "Lorem Ipsum Dolor"
		 */
		public static function toProperCase(str:String):String {
			function capsFn():String {
				return arguments[0].toUpperCase();
			}
			return str.toLowerCase().replace(/^[a-z\xE0-\xFF]|\s[a-z\xE0-\xFF]/g, capsFn); //replaces first letter of each word
		}
		
		/**
		 * Remove " " and "-" and convert to camel case
		 * - ex: StringUtils.toCamelCase("lorem ipsum-dolor") returns "loremIpsumDolor"
		 */
		public static function toCamelCase(str:String):String {
			str = str.replace("-", " ");
			str = toProperCase(str).replace(" ", "");
			// lowercase first letter
			function capsFn():String {
				return arguments[0].toLowerCase();
			}
			return str.replace(/\b\w/g, capsFn);
		}
		
		/**
		 * Replaces all chars with accents to regular ones
		 * - ex:  StringUtils.replaceAccents("Téçãö ý À æ ?#special-example"); returns "Tecao y A ae ?#special-example"
		 */
		public static function replaceAccents(str:String):String {
			
			// verifies if the String has accents and replace accents
			if (str.search(/[\xc0-\xff]/g) > -1) {
				str = str.replace(/[\xC0-\xC5]/g, "A");
				str = str.replace(/[\xC6]/g, "AE");
				str = str.replace(/[\xC7]/g, "C");
				str = str.replace(/[\xC8-\xCB]/g, "E");
				str = str.replace(/[\xCC-\xCF]/g, "I");
				str = str.replace(/[\xD0]/g, "D");
				str = str.replace(/[\xD1]/g, "N");
				str = str.replace(/[\xD2-\xD6\xD8]/g, "O");
				str = str.replace(/[\xD9-\xDC]/g, "U");
				str = str.replace(/[\xDD]/g, "Y");
				str = str.replace(/[\xE0-\xE5]/g, "a");
				str = str.replace(/[\xE6]/g, "ae");
				str = str.replace(/[\xE7]/g, "c");
				str = str.replace(/[\xE8-\xEB]/g, "e");
				str = str.replace(/[\xEC-\xEF]/g, "i");
				str = str.replace(/[\xF1]/g, "n");
				str = str.replace(/[\xF2-\xF6\xF8]/g, "o");
				str = str.replace(/[\xF9-\xFC]/g, "u");
				str = str.replace(/[\xFD\xFF]/g, "y");
			}
			return str;
			
		}
		
		/**
		 * Remove all non word chars (keep only [a-z] [A-Z] [0-9] space, "-" and chars with accents )
		 * - ex: StringUtils.removeNonWordChars("Téçãö ý À æ ?#special-example")  returns  "Téçãö ý À æ special-example"
		 */
		public static function removeNonWordChars(str:String, replace:String = ""):String {
			return str.replace(/[^\w \-\xC0-\xFF]/g, replace);
		}
		
		/**
		 * Remove all special chars (keep only [a-z] [A-Z] [0-9] space and "-", "_" )
		 * - ex: StringUtils.removeSpecialChars("Téçãö ý À æ ?#special-example")  returns  "T    special-example"
		 */
		public static function removeSpecialChars(str:String, replace:String = ""):String {
			return str.replace(/[^\w \_\-]/g, replace);
		}
		
		/**
		 * Convert all multiple spaces into single spaces
		 * - ex: StringUtils.removeMultipleSpaces("lorem     ipsum  dolor")  returns  "lorem ipsum dolor"
		 */
		public static function removeMultipleSpaces(str:String, replace:String = ""):String {
			return str.replace(/ {2,}/g, replace);
		}
		
		/**
		 * Remove all line breaks
		 */
		public static function removeLineBreaks(str:String, replace:String = ""):String {
			return str.replace(/\r|\n/g, replace);
		}
		
		/**
		 * Remove all tabs
		 */
		public static function removeTabs(str:String, replace:String = ""):String {
			return str.replace(/\t/g, replace);
		}
		
		/**
		 * Remove all tabs, line breaks and spaces
		 */
		public static function removeAllWhiteSpaces(str:String, replace:String = ""):String {
			return str.replace(/\s/g, replace);
		}
		
		/**
		 * Remove all spaces
		 * - ex: StringUtils.removeSpaces("lorem     ipsum  dolor")  returns  "loremipsumdolor"
		 */
		public static function removeSpaces(str:String, replace:String = ""):String {
			return str.replace(/ +/g, replace);
		}
		
		/**
		 * Remove white spaces at the begining and end of the string
		 * - ex: ex: StringUtils.trim("  lorem ipsum dolor  ")  returns  "lorem ipsum dolor"
		 */
		public static function trim(str:String):String {
			return ltrim(rtrim(str));
		}
		
		/**
		 * Remove white spaces at the begining of a string
		 * - ex: ex: StringUtils.ltrim("  lorem ipsum dolor  ")  returns  "lorem ipsum dolor  "
		 */
		public static function ltrim(str:String):String {
			return str.replace(/^\s*/, "");
		}
		
		/**
		 * Remove white spaces at the end of a string
		 * - ex: ex: StringUtils.rtrim("  lorem ipsum dolor  ")  returns  "  lorem ipsum dolor"
		 */
		public static function rtrim(str:String):String {
			return str.replace(/\s*$/, "");
		}
		
		/**
		 * Remove everything inside multi line or single line comments 
		 */
		public static function removeAllComments(str:String, replace:String = ""):String {
			return removeMultiLineComments(removeSingleLineComments(str, replace), replace);
		}
		
		/**
		 * Remove everything inside multi line comments
		 */
		public static function removeMultiLineComments(str:String, replace:String = ""):String {
			return str.replace(/\/\*.+?(?:\*\/)/gs, replace);
		}
		
		/**
		 * Remove everything inside single line comments
		 */
		public static function removeSingleLineComments(str:String, replace:String = ""):String {
			return str.replace(/\/\/[^\n\r]+/gs, replace);
		}
	}
	
}