package com.millermedeiros.utils {
	
	/**
	 * ColorUtils
	 * @author Miller Medeiros (http://www.millermedeiros.com)
	 * @version	0.4.1 (2011/01/18)
	 */
	public final class ColorUtils {
		
		private static var _htmlColors:Object;
		private static var _isHtmlColorsInit:Boolean = false;
		
		/**
		 * @private
		 */
		public function ColorUtils() {
			throw new Error("STATIC Class and should not be instantiated.");
		}
		
		/**
		 * Split each color channel and return the fade between the 2 colors based on current color ratio/position
		 * @param	startColor	RGB hexadecimal color - color at the position 0
		 * @param	endColor	RGB hexadeciaml color - color at the position 1
		 * @param	position	Color position ratio (between 0 and 1)
		 * @return	Color value
		 */
		public static function fadeColor(startColor:uint, endColor:uint, position:Number):uint {
			var r:uint = startColor >> 16;
			var g:uint = startColor >> 8 & 0xFF;
			var b:uint = startColor & 0xFF;
			r += ((endColor >> 16) - r) * position;
			g += ((endColor >> 8 & 0xFF) - g) * position;
			b += ((endColor & 0xFF) - b) * position;
			return (r << 16 | g << 8 | b);
		}
		
		/**
		 * Convert rgb(255,255,255) to uint hex color
		 * @param	rgb	Color value - ex:"rgb(255,255,255)" or "rgb(100%,100%,100%)"
		 * @return	Color uint value
		 * @example	ColorsUtils.rgbToUint("rgb(255,255,255)") return 0xFFFFFF;
		 */
		public static function rgbToUint(rgb:String):uint {
			var colors:Array = rgb.replace(" ", "").replace(/[()]/g,"").substr(3).split(",");
			var r:uint = (isNaN(colors[0]))? percToUint(colors[0]) : colors[0];
			var g:uint = (isNaN(colors[1]))? percToUint(colors[1]) : colors[1];
			var b:uint = (isNaN(colors[2]))? percToUint(colors[2]) : colors[2];
			return (r << 16 | g << 8 | b);
		}
		
		/**
		 * Convert rgb(255,255,255) to html hex color
		 * @param	rgb	Color value - ex:"rgb(255,255,255)" or "rgb(100%,100%,100%)"
		 * @return	Hexadecimal color
		 * @example	ColorsUtils.rgbToHex("rgb(255,255,255)") return "#FFFFFF";
		 */
		public static function rgbToHex(rgb:String):String {
			return uintToHex(rgbToUint(rgb));
		}
		
		/**
		 * Convert percent to hex uint number
		 * @param	perc	Color percent (between 0% and 100%)
		 * @return	uint between 0 and 255
		 * @private
		 */
		private static function percToUint(perc:String):uint {
			return uint(perc.replace("%", "")) * 2.55;
		}
		
		/**
		 * Convert html hexadecimal color to flash uint color
		 * @param	hex	Hexadecimal color
		 * @return	flash uint color
		 * @example	ColorUtils.hexToUint("#FF0000") return 0xFF0000
		 */
		public static function hexToUint(hex:String):uint {
			hex = hex || "";
			hex = hex.replace("#", "").toUpperCase();
			if (hex.length == 3) hex = hex.replace(/(\w)/g, "$&$&"); //converts FC0 to FFCC00
			return uint("0x" + hex);
		}
		
		/**
		 * Convert uint color to hexadecimal
		 * @param	u	uint Color
		 * @return	Hexadecimal value
		 * @example	ColorUtils.uintToHex(0xFF0000) return "#FF0000"
		 */
		public static function uintToHex(u:uint):String {
			return "#" + u.toString(16).toUpperCase();
		}
		
		/**
		 * Convert a html color name to hexadecimal color
		 * @param	htmlColorName
		 * @return	Hexadecimal color
		 * @example	ColorUtils.htmlColorToHex("red") returns "#FF0000"
		 */
		public static function htmlColorToHex(htmlColorName:String):String {
			if (!_isHtmlColorsInit) initializeHtmlColors();
			return _htmlColors[htmlColorName.toLowerCase()];
		}
		
		/**
		 * Convert a html color name to uint hexadecimal color
		 * @param	htmlColorName
		 * @return	uint hexadecimal color
		 * @example	htmlColorToHex("red") returns 0xFF0000
		 */
		public static function htmlColorToUint(htmlColorName:String):uint {
			return hexToUint(htmlColorToHex(htmlColorName));
		}
		
		/**
		 * Convert string color to Uint
		 * @param	color	Color in 'rgb(255,255,255)' or '#FFFFFF' or '#FFF' or 'white' or '0xFFFFFF' formats
		 * @return	Uint color value
		 * @example	ColorUtils.colorToUint("white") returns 0xFFFFFF
		 */
		public static function colorToUint(color:String):uint {
			if(/^rgb\(\d+\,\d+\,\d+\)/.test(color)){
				return rgbToUint(color);
			} else if(/^\#(:?\w{6}|\w{3})/.test(color)) {
				return hexToUint(color);
			} else if(/^[a-zA-Z]+/.test(color)){
				return htmlColorToUint(color);
			} else {
				return uint(color);
			}
		}
		
		/**
		 * Convert color to Hex String
		 * @param	color	Color in 'rgb(255,255,255)' or '#FFFFFF' or '#FFF' or 'white' or '0xFFFFFF' formats
		 * @return	String hexadecimal color value
		 * @example	ColorUtils.colorToHex("white") returns '#FFFFFF'
		 */
		public static function colorToHex(color:*):String {
			if(isNaN(color)){
				if(/\#(:?\w{6}|\w{3})/.test(color)) {
					return color;
				}else if (/rgb\(\d+\,\d+\,\d+\)/.test(color)) {
					return rgbToHex(color);
				}else if (/[a-z]+/.test(color)) {
					return htmlColorToHex(color);
				}else {
					return '#000000';
				}
			}else {
				return uintToHex(color);
			}
		}
		
		/**
		 * Initialize HTML colors, used to avoid memory use without need
		 */
		private static function initializeHtmlColors():void {
			_htmlColors = {
				aliceblue : "#F0F8FF",
				antiquewhite : "#FAEBD7",
				aqua : "#00FFFF",
				aquamarine : "#7FFFD4",
				azure : "#F0FFFF",
				beige : "#F5F5DC",
				bisque : "#FFE4C4",
				black : "#000000",
				blanchedalmond : "#FFEBCD",
				blue : "#0000FF",
				blueviolet : "#8A2BE2",
				brown : "#A52A2A",
				burlywood : "#DEB887",
				cadetblue : "#5F9EA0",
				chartreuse : "#7FFF00",
				chocolate : "#D2691E",
				coral : "#FF7F50",
				cornflowerblue : "#6495ED",
				cornsilk : "#FFF8DC",
				crimson : "#DC143C",
				cyan : "#00FFFF",
				darkblue : "#00008B",
				darkcyan : "#008B8B",
				darkgoldenrod : "#B8860B",
				darkgray : "#A9A9A9",
				darkgreen : "#006400",
				darkgrey : "#A9A9A9",
				darkkhaki : "#BDB76B",
				darkmagenta : "#8B008B",
				darkolivegreen : "#556B2F",
				darkorange : "#FF8C00",
				darkorchid : "#9932CC",
				darkred : "#8B0000",
				darksalmon : "#E9967A",
				darkseagreen : "#8FBC8F",
				darkslateblue : "#483D8B",
				darkslategray : "#2F4F4F",
				darkslategrey : "#2F4F4F",
				darkturquoise : "#00CED1",
				darkviolet : "#9400D3",
				deeppink : "#FF1493",
				deepskyblue : "#00BFFF",
				dimgray : "#696969",
				dimgrey : "#696969",
				dodgerblue : "#1E90FF",
				firebrick : "#B22222",
				floralwhite : "#FFFAF0",
				forestgreen : "#228B22",
				fuchsia : "#FF00FF",
				gainsboro : "#DCDCDC",
				ghostwhite : "#F8F8FF",
				gold : "#FFD700",
				goldenrod : "#DAA520",
				gray : "#808080",
				green : "#008000",
				greenyellow : "#ADFF2F",
				grey : "#808080",
				honeydew : "#F0FFF0",
				hotpink : "#FF69B4",
				indianred : " #CD5C5C",
				indigo : " #4B0082",
				ivory : "#FFFFF0",
				khaki : "#F0E68C",
				lavender : "#E6E6FA",
				lavenderblush : "#FFF0F5",
				lawngreen : "#7CFC00",
				lemonchiffon : "#FFFACD",
				lightblue : "#ADD8E6",
				lightcoral : "#F08080",
				lightcyan : "#E0FFFF",
				lightgoldenrodyellow : "#FAFAD2",
				lightgray : "#D3D3D3",
				lightgreen : "#90EE90",
				lightgrey : "#D3D3D3",
				lightpink : "#FFB6C1",
				lightsalmon : "#FFA07A",
				lightseagreen : "#20B2AA",
				lightskyblue : "#87CEFA",
				lightslategray : "#778899",
				lightslategrey : "#778899",
				lightsteelblue : "#B0C4DE",
				lightyellow : "#FFFFE0",
				lime : "#00FF00",
				limegreen : "#32CD32",
				linen : "#FAF0E6",
				magenta : "#FF00FF",
				maroon : "#800000",
				mediumaquamarine : "#66CDAA",
				mediumblue : "#0000CD",
				mediumorchid : "#BA55D3",
				mediumpurple : "#9370D8",
				mediumseagreen : "#3CB371",
				mediumslateblue : "#7B68EE",
				mediumspringgreen : "#00FA9A",
				mediumturquoise : "#48D1CC",
				mediumvioletred : "#C71585",
				midnightblue : "#191970",
				mintcream : "#F5FFFA",
				mistyrose : "#FFE4E1",
				moccasin : "#FFE4B5",
				navajowhite : "#FFDEAD",
				navy : "#000080",
				oldlace : "#FDF5E6",
				olive : "#808000",
				olivedrab : "#6B8E23",
				orange : "#FFA500",
				orangered : "#FF4500",
				orchid : "#DA70D6",
				palegoldenrod : "#EEE8AA",
				palegreen : "#98FB98",
				paleturquoise : "#AFEEEE",
				palevioletred : "#D87093",
				papayawhip : "#FFEFD5",
				peachpuff : "#FFDAB9",
				peru : "#CD853F",
				pink : "#FFC0CB",
				plum : "#DDA0DD",
				powderblue : "#B0E0E6",
				purple : "#800080",
				red : "#FF0000",
				rosybrown : "#BC8F8F",
				royalblue : "#4169E1",
				saddlebrown : "#8B4513",
				salmon : "#FA8072",
				sandybrown : "#F4A460",
				seagreen : "#2E8B57",
				seashell : "#FFF5EE",
				sienna : "#A0522D",
				silver : "#C0C0C0",
				skyblue : "#87CEEB",
				slateblue : "#6A5ACD",
				slategray : "#708090",
				slategrey : "#708090",
				snow : "#FFFAFA",
				springgreen : "#00FF7F",
				steelblue : "#4682B4",
				tan : "#D2B48C",
				teal : "#008080",
				thistle : "#D8BFD8",
				tomato : "#FF6347",
				turquoise : "#40E0D0",
				violet : "#EE82EE",
				wheat : "#F5DEB3",
				white : "#FFFFFF",
				whitesmoke : "#F5F5F5",
				yellow : "#FFFF00",
				yellowgreen : "#9ACD32"
			}
			_isHtmlColorsInit = true;
		}
		
		/**
		 * Release memory used by Html colors
		 */
		public static function cleanHtmlColors():void {
			_htmlColors = null;
			_isHtmlColorsInit = false;
		}
		
	}
	
}