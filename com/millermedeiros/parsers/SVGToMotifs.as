/**
 * Copyright (c) 2009 Miller Medeiros <http://www.millermedeiros.com/>
 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
 */

 //TODO: remove unnecessary lineStyle commands to reduce Motifs size
 //TODO: fix spiral fill bug (don't think it's a big problem since spirals aren't commom)
 //TODO: support CSS classes (maybe)
 
package com.millermedeiros.parsers {
	
	import com.millermedeiros.geom.Arc;
	import com.millermedeiros.geom.CubicBezier;
	import com.millermedeiros.geom.Ellipse;
	import com.millermedeiros.geom.Line;
	import com.millermedeiros.geom.Polygon;
	import com.millermedeiros.geom.Polyline;
	import com.millermedeiros.geom.QuadraticBezier;
	import com.millermedeiros.geom.Rect;
	import com.millermedeiros.geom.SVGArc;
	import com.millermedeiros.utils.ArrayUtils;
	import com.millermedeiros.utils.ColorUtils;
	import com.millermedeiros.utils.GeomUtils;
	import com.millermedeiros.utils.MatrixUtils;
	import com.millermedeiros.utils.NumberUtils;
	import com.millermedeiros.utils.ObjectUtils;
	import com.millermedeiros.utils.StringUtils;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	/**
	 * Parses a SVG file into a motifs array
	 * @author Miller Medeiros (www.millermedeiros.com)
	 * @since 2009/07/22
	 * @version	0.1
	 */
	public final class SVGToMotifs {
		
		private static var _eWarnings:Array = []; // Elements warnings
		private static var _aWarnings:Array = []; // Attributes warnings
		private static var _pWarnings:Array = []; // Path draw warnings
		private static var _tWarnings:Array = []; // Transform warnings
		private static var _motifs:Array = []; // Graphics3D motifs
		private static var _initAnchor:Point; // Store Path initial anchor point for close path command
		private static var _prevAnchor:Point; // Store Path previous anchor point for relative draw
		private static var _prevControl:Point; // Store Path previous anchor point for smooth curves
		private static var _prevCommand:String; // Store Path previous command (used for smooth bezier)
		private static var _curMatrix:Matrix; // Current Transformation Matrix (applied to objects that have transformation matrix)
		private static var _hasTransform:Boolean; // If the element has a transformation Matrix applied (used to avoid aplying transform to all elements)
		private static var _warnings:String = ""; //Warnings text
		
		/// supported attributes
		private static const SUPPORTED_ATT:Array = [
			"cx",
			"cy",
			"d",
			"fill",
			"fill-opacity",
			"height",
			"opacity",
			"points",
			"r",
			"rx",
			"ry",
			"stroke",
			"stroke-linecap",
			"stroke-linejoin",
			"stroke-miterlimit",
			"stroke-opacity",
			"stroke-width",
			"style",
			"transform",
			"width",
			"x",
			"x1",
			"x2",
			"y",
			"y1",
			"y2"
		];
		
		/**
		 * Static Class
		 * @private
		 */
		public function SVGToMotifs() {
			throw new Error("This is a STATIC CLASS and should not be instantiated.");
		}
		
		/**
		 * Parse SVG file and return a motifs array
		 * @param	svg	SVG file to be parsed
		 * @return	Motifs array
		 */
		public static function parse(svg:String):Array {
			
			_motifs.length = 0; //faster than creating a new Array
			clearWarnings();
			
			// reset points (used for close path and smooth bezier)
			_initAnchor = new Point();
			_prevAnchor = new Point();
			_prevControl = new Point();
			
			_curMatrix = new Matrix();
			
			// parse SVG tags
			svg = svg.replace(/[a-zA-Z]*:[a-zA-Z]+="(?:[\w]*[\/:\.#;,\s+=]*)*"/g, ""); //remove namespaces and base64 image data (to avoid bugs)
			var elements:XML = new XML("<svg>" + svg.replace(/<\??xml[^>]*>|<![^>]*>|<\/?svg[^>]*>|\t|\r|\n/g, "") +"</svg>"); //remove tags <xml> <svg> and their attributes. also removes tabs and line breaks (to avoid bugs)
			parseTags(elements.children());
			
			// WARNINGS / ERRORS
			_warnings += (_eWarnings.length)? "WARNING: Elements [" + _eWarnings.join(", ") + "] are not supported and will be ignored.\n" : "";
			_warnings += (_aWarnings.length)? "WARNING: Attributes [" + _aWarnings.join(", ") + "] are not supported and will be ignored.\n" : "";
			_warnings += (_pWarnings.length)? "WARNING: Path drawing commands [" + _pWarnings.join(", ") + "] are not supported and will be ignored.\n" : "";
			_warnings += (_tWarnings.length)? "WARNING: Transform commands [" + _tWarnings.join(", ") + "] are not supported and will be ignored.\n" : "";
			
			return _motifs;
			
		}
		
		static private function clearWarnings():void{
			_eWarnings.length = _aWarnings.length = _pWarnings.length = _tWarnings.length = 0; //faster than creating new arrays
			_warnings = "";
		}
		
		/**
		 * Parse tags and attributes
		 * @param	elm	Elements
		 * @param	parentAtt	Parent group attributes (used for inheritance)
		 */
		private static function parseTags(elm:XMLList, parentAtt:Object = null):void {
			var tagName:String = "";
			var elmAtt:Object = { };
			var m:int = elm.length();
			for (var i:int = 0; i < m; i++) {
				tagName = elm[i].name();
				elmAtt = mergeAttributes(parentAtt, parseAttributes(elm[i].attributes()));//inheritance
				if(tagName != "g"){
					parseElements(tagName, elmAtt);
				}else {
					parseTags(elm[i].children(), elmAtt); //inheritance
				}
			}
		}
		
		/**
		 * Parse attributes
		 * @param	attList	Attributes list
		 * @return	Attributes object
		 */
		private static function parseAttributes(attList:XMLList):Object {
			var n:int = attList.length();
			var att:Object = { };
			var aName:String = "";
			while (n--) {
				aName = String(attList[n].name());
				att[aName] = (aName != "transform")? attList[n] : parseTransform(attList[n]);
				validateAttribute(aName);
			}
			//inline style support (overwrite all attributes/css classes)
			if (att["style"] != undefined) {
				var styleStr:String = String(att["style"]).replace(/\;/g, ",");
				var styleObj:Object = ObjectUtils.toObject(styleStr);
				for (var prop:String in styleObj) {
					att[prop] = styleObj[prop];
				}
			}
			return att;
		}
		
		/**
		 * Validate attributes
		 * @param	att	Attribute Name
		 */
		private static function validateAttribute(att:String):void {
			if(SUPPORTED_ATT.indexOf(att) < 0){
				if (_aWarnings.indexOf(att) < 0) _aWarnings.push(att);
			}
		}
		
		/**
		 * Merge 2 attributes objects (used for inheritance)
		 * @param	base	Base object
		 * @param	extend	Object that should replace base properties
		 * @return	Attributes Object
		 */
		private static function mergeAttributes(base:Object, extend:Object):Object {
			var merged:Object = { };
			for (var key:String in base) merged[key] = base[key];
			for (var prop:String in extend) {
				if (prop == "opacity" && merged.hasOwnProperty(prop)) {
					merged[prop] = Number(merged[prop]) * Number(extend[prop]); //opacity is cumulative
				}else if (prop == "transform" && merged.hasOwnProperty(prop)){
					Matrix(extend[prop]).concat(Matrix(merged[prop]));
					merged[prop] = extend[prop];
				}else {
					merged[prop] = extend[prop];
				}
			}
			return merged;
		}
		
		//--------------- ELEMENTS PARSER -------------//
		
		/**
		 * Parse elements
		 * @param	type	Element type
		 * @param	attributes	Element attributes
		 */
		private static function parseElements(type:String, att:Object):void {
			
			//beginFill
			if (att['fill'] != "none") {
				var fillColor:uint = (att['fill'] != undefined)? ColorUtils.colorToUint(att['fill']) : 0;
				var fillOpacity:Number = (att['fill-opacity'] != undefined)? att['fill-opacity'] : 1;
				fillOpacity *= (att['opacity'] != undefined)? att['opacity'] : 1;
				_motifs.push( ['B', [fillColor, NumberUtils.limitPrecision(fillOpacity)]] );
			}else if (type == 'line') {
				att['fill'] = 0;
				_motifs.push( ['B', []] ); //fix unfilled line bug
			}
			
			//lineStyle
			if (att['stroke'] != undefined || att['stroke-width'] != undefined) {
				var thickness:Number = (att['stroke-width'] != undefined)? att['stroke-width'] : 1;
				var strokeColor:uint = (att['stroke'] != undefined)? ColorUtils.colorToUint(att['stroke']) : 0;
				var strokeOpacity:Number = (att['stroke-opacity'] != undefined)? att['stroke-opacity'] : 1;
				strokeOpacity *= (att['opacity'] != undefined)? att['opacity'] : 1;
				var caps:String = (att['stroke-linecap'] != undefined && att['stroke-linecap'] != "butt")? att['stroke-linecap'] : "none";
				var joints:String = (att['stroke-linejoin'] != undefined)? att['stroke-linejoin'] : null;
				var miterlimit:Number = (att['stroke-miterlimit'] != undefined)? att['stroke-miterlimit'] : 3;
				_motifs.push( ['S', [NumberUtils.limitPrecision(thickness), strokeColor, NumberUtils.limitPrecision(strokeOpacity), false, "normal", caps, joints, miterlimit]] );
			} else {
				_motifs.push( ['S', []] ); //clear lineStyle
			}
			
			//transform matrix
			if(att.transform){
				_curMatrix = att.transform;
				_hasTransform = true;
			}else {
				_hasTransform = false;
			}
			
			//shapes
			switch (type) {
				case "circle":
					eCircle(att['cx'], att['cy'], att['r']);
					break;
				case "ellipse":
					eEllipse(att['cx'], att['cy'], att['rx'], att['ry']);
					break;
				case "line":
					eLine(att['x1'], att['y1'], att['x2'], att['y2']);
					break;
				case "path":
					ePath(att['d']);
					break;
				case "polygon":
					ePolygon(att['points']);
					break;
				case "polyline":
					ePolyline(att['points']);
					break;
				case "rect":
					eRect(int(att['x']), int(att['y']), att['width'], att['height'], int(att['rx']), int(att['ry']));
					break;
				default:
					if(_eWarnings.indexOf(type) < 0) _eWarnings.push(type); // Add element warning
					break;
			}
			
			//endFill
			if (att['fill'] != "none"){
				_motifs.push( ['E'] );
			}
			
		}
		
		/**
		 * Convert transform attribute into a Matrix
		 * @param	str	transform attribute
		 * @return	Matrix that represents all transformations
		 */
		static private function parseTransform(str:String):Matrix{
			var mat:Matrix = new Matrix();
			var transforms:Array = str.match(/[a-zA-Z]+\([\d-., ]+\)/g); //split all commands and params
			var command:String;
			var params:Array = [];
			var n:int = transforms.length;
			while (n--) {
				command = String(transforms[n]).match(/[a-zA-Z]+/g)[0];
				params = String(transforms[n]).match(/[-\d.]+/g);
				switch(command) {
					case "matrix":
						mat.concat(new Matrix(params[0], params[1], params[2], params[3], params[4], params[5]));
						break;
					case "rotate":
						if (params.length > 1) {
							mat = MatrixUtils.rotateAroundExternalPoint(mat, new Point(params[1], params[2]), params[0]);
						}else {
							mat.rotate(GeomUtils.degreeToRadians(params[0]));
						}
						break;
					case "scale":
						if (params.length == 1) params[1] = params[0]; //If <sy> is not provided, it is assumed to be equal to <sx>
						mat.scale(params[0], params[1]);
						break;
					case "skewX":
						var sX:Number = MatrixUtils.getSkewX(mat);
						mat = MatrixUtils.setSkewX(mat, sX + params[0]);
						break;
					case "skewY":
						var sY:Number = MatrixUtils.getSkewY(mat);
						mat = MatrixUtils.setSkewY(mat, sY + params[0]);
						break;
					case "translate":
						mat.translate(params[0], params[1]);
						break;
					default:
						if(_tWarnings.indexOf(command) < 0) _tWarnings.push(command); // Add transform warning
						break;
				}
			}
			return mat;
		}
		
		/**
		 * Circle
		 * @param	cx	Center X
		 * @param	cy	Center Y
		 * @param	r	Radius
		 */
		private static function eCircle(cx:Number, cy:Number, r:Number):void {
			var circle:Ellipse = new Ellipse(cx, cy, r, r);
			if(_hasTransform) circle = circle.transform(_curMatrix);
			_motifs = _motifs.concat(circle.toMotifs());
		}
		
		/**
		 * Ellipse
		 * @param	cx	Center X
		 * @param	cy	Center Y
		 * @param	rx	Radius X
		 * @param	ry	Radius Y
		 */
		private static function eEllipse(cx:Number, cy:Number, rx:Number, ry:Number):void {
			var ellipse:Ellipse = new Ellipse(cx, cy, rx, ry);
			if(_hasTransform) ellipse = ellipse.transform(_curMatrix);
			_motifs = _motifs.concat(ellipse.toMotifs());
		}
		
		/**
		 * Line
		 * @param	x1	Start X
		 * @param	y1	Start Y
		 * @param	x2	End X
		 * @param	y2	End Y
		 */
		private static function eLine(x1:Number, y1:Number, x2:Number, y2:Number):void {
			var line:Line = new Line(new Point(x1, y1), new Point(x2, y2));
			if(_hasTransform) line = line.transform(_curMatrix);
			_motifs = _motifs.concat(line.toMotifs());
		}
		
		/**
		 * Path
		 * @param	d	Path data commands
		 */
		private static function ePath(d:String):void {
			
			_initAnchor.x = _initAnchor.y = _prevAnchor.x = _prevAnchor.y = _prevControl.x = _prevControl.y = _prevControl.x = _prevControl.y = 0;
			
			var commands:Array = d.match(/(?:[a-zA-Z] ?(?:[0-9.-],? ?)+)|(?:z|Z)/g); //split all commands
			var n:int = commands.length;
			var temp:String = "";
			
			for (var i:int = 0; i < n; i++) {
				temp = StringUtils.trim(StringUtils.removeMultipleSpaces(commands[i]));
				temp = temp.replace(/([a-zA-Z]) /g, "$1"); //remove space after "command char"
				temp = StringUtils.removeAllWhiteSpaces(temp, ",");
				temp = temp.replace(/((?<![a-zA-Z]|,)-)/g, ",$&"); //add "," before all "-" but the ones that already have a comma before it and the ones that are just after a "commmand char"
				commands[i] = (temp.length > 1)? [temp.substr(0, 1), temp.substr(1).split(",")] : [temp.substr(0, 1)]; //[command, [params...]]
			}
			
			//TODO: TEST close path
			if (String(commands[0][0]).toLowerCase() == "m") {
				_initAnchor.x = commands[0][1][0];
				_initAnchor.y = commands[0][1][1];
				if(_hasTransform) _initAnchor = _curMatrix.transformPoint(_initAnchor);
			}
			
			_prevCommand = null;
			
			for (var j:int = 0; j < n; j++) {
				
				switch (commands[j][0]) {
					case "A":
						pArc(commands[j][1]);
						break;
					case "a":
						pArc(commands[j][1], true);
						break;
					case "C":
						pCubic(commands[j][1]);	
						break;
					case "c":
						pCubic(commands[j][1], true);
						break;
					case "H":
						pLine(commands[j][1][0], _prevAnchor.y);
						break;
					case "h":
						pLine(toAbsoluteX(commands[j][1][0]), _prevAnchor.y);
						break;
					case "L":
						pLine(commands[j][1][0], commands[j][1][1]);
						break;
					case "l":
						pLine(toAbsoluteX(commands[j][1][0]), toAbsoluteY(commands[j][1][1]));
						break;
					case "M":
						pMove(commands[j][1][0], commands[j][1][1]);
						break;
					case "m":
						pMove(toAbsoluteX(commands[j][1][0]), toAbsoluteY(commands[j][1][1]));
						break;
					case "Q":
						pQuad(commands[j][1]);
						break;
					case "q":
						pQuad(commands[j][1], true);
						break;
					case "S":
						pSmoothCubic(commands[j][1]);
						break;
					case "s":
						pSmoothCubic(commands[j][1], true);
						break;
					case "T":
						pSmoothQuad(commands[j][1]);
						break;
					case "t":
						pSmoothQuad(commands[j][1], true);
						break;
					case "V":
						pLine(_prevAnchor.x, commands[j][1][0]);
						break;
					case "v":
						pLine(_prevAnchor.x, toAbsoluteY(commands[j][1][0]));
						break;
					case "Z":
					case "z":
						pClose();
						break;
					default:
						if(_pWarnings.indexOf(commands[j][0]) < 0) _pWarnings.push(commands[j][0]); // Add path drawing warning
						break;
				}
				
				_prevCommand = commands[j][0];
				
			}
			
			if (String(commands[commands.length - 1][0]).toLowerCase() != "z" || commands[commands.length - 1][1] != commands[0][1]) _motifs.push( ['S', []] ); //remove last line if path is not closed
			
		}
		
		/**
		 * Polygon
		 * @param	pts	Polygon points
		 * @param	isClosed	if it is a polygon (closed) or polyline (not closed)
		 */
		private static function ePolygon(pts:String, isClosed:Boolean = true):void {
			
			var pArr:Array = StringUtils.removeMultipleSpaces(StringUtils.trim(pts)).split(" ");
			var n:int = pArr.length;
			
			while (n--) {
				pArr[n] = pArr[n].split(",");
				pArr[n] = new Point(pArr[n][0], pArr[n][1]);
			}
			
			if (isClosed) {
				var polygon:Polygon = new Polygon(pArr);
				if(_hasTransform) polygon = polygon.transform(_curMatrix);
				_motifs = _motifs.concat(polygon.toMotifs());
			}else {
				var polyline:Polyline = new Polyline(pArr);
				if(_hasTransform) polyline = polyline.transform(_curMatrix);
				_motifs = _motifs.concat(polyline.toMotifs());
			}
			
		}
		
		/**
		 * Polyline
		 * @param	pts	Polyline points
		 */
		private static function ePolyline(pts:String):void {
			ePolygon(pts, false);
		}
		
		/**
		 * Rectangle
		 * @param	x	X position
		 * @param	y	Y position
		 * @param	wid	Width
		 * @param	hei	Height
		 * @param	rx	Radius X (rounded rectangle)
		 * @param	ry	Radius Y (rounded rectangle)
		 */
		private static function eRect(x:Number, y:Number, wid:Number, hei:Number, rx:Number = 0, ry:Number = 0):void {
			var rect:Rect = new Rect(x, y, wid, hei, rx, ry);
			if(_hasTransform) rect = rect.transform(_curMatrix);
			_motifs = _motifs.concat(rect.toMotifs());
		}
		
		//--------------- PATHS DATA PARSER -------------//
		
		/**
		 * Elliptical Arc
		 * @param	params
		 * @param	isRelative
		 */
		private static function pArc(params:Array, isRelative:Boolean = false):void {
			var end:Point = new Point(params[5], params[6]);
			if (isRelative)	toAbsolute(end);
			var arc:SVGArc = new SVGArc(_prevAnchor, end, params[0], params[1], params[2], (params[3] == '1'), (params[4] == '1'));
			if (_hasTransform) {
				arc.matrix = _curMatrix;
				end = _curMatrix.transformPoint(end);
			}
			_motifs = _motifs.concat(arc.toMotifs(false));
			_prevAnchor = end;
		}
		
		/**
		 * Cubic Bezier Curve
		 * @param	params	[c1x, c1y, c2x, c2y, x, y]
		 * @param	isRelative	Use relative positions
		 */
		private static function pCubic(params:Array, isRelative:Boolean = false):void {
			var c1:Point = new Point(params[0], params[1]);
			var c2:Point = new Point(params[2], params[3]);
			var p2:Point = new Point(params[4], params[5]);
			if (isRelative) {
				toAbsolute(c1);
				toAbsolute(c2);
				toAbsolute(p2);
			}
			var bezier:CubicBezier = new CubicBezier(c1, c2, _prevAnchor, p2);
			if(_hasTransform) bezier = bezier.transform(_curMatrix);
			_motifs = _motifs.concat(bezier.toMotifs());
			_prevAnchor = p2;
			_prevControl = c2;
		}
		
		/**
		 * Smooth Cubic Bezier Curve
		 * @param	params	[c2x, c2y, x, y]
		 * @param	isRelative	Use relative positions
		 */
		private static function pSmoothCubic(params:Array, isRelative:Boolean = false):void {
			var c1:Point = (_prevCommand.toUpperCase() == "C" || _prevCommand.toUpperCase() == "S")? GeomUtils.reflectPoint(_prevControl, _prevAnchor) : _prevAnchor;
			if (isRelative) toRelative(c1);
			pCubic([c1.x, c1.y, params[0], params[1], params[2], params[3]], isRelative);
		}
		
		/**
		 * LineTo
		 */
		private static function pLine(endX:Number, endY:Number):void {
			var p:Point = new Point(endX, endY);
			_prevAnchor = p; //should be stored before transform
			if (_hasTransform) p = _curMatrix.transformPoint(p);
			_motifs.push(['L', [NumberUtils.limitPrecision(p.x), NumberUtils.limitPrecision(p.y)]]);
		}
		
		/**
		 * MoveTo
		 */
		private static function pMove(x:Number, y:Number):void {
			var p:Point = new Point(x, y);
			_prevAnchor = p; //should be stored before transform
			if (_hasTransform) p = _curMatrix.transformPoint(p);
			_motifs.push(['M', [NumberUtils.limitPrecision(p.x), NumberUtils.limitPrecision(p.y)]]);
		}
		
		/**
		 * Quadratic Bezier Curve
		 * @param	params	[c1x, c1y, x, y]
		 * @param	isRelative	Use relative positions
		 */
		private static function pQuad(params:Array, isRelative:Boolean = false):void {
			var c:Point = new Point(params[0], params[1]);
			var p2:Point = new Point(params[2], params[3]);
			if (isRelative) {
				toRelative(c);
				toRelative(p2);
			}
			var quad:QuadraticBezier = new QuadraticBezier(c, _prevAnchor, p2);
			if(_hasTransform) quad.transform(_curMatrix);
			_motifs = _motifs.concat(quad.toMotifs());
			_prevControl = c;
			_prevAnchor = p2;
		}
		
		/**
		 * Smooth Quadratic Bezier Curve
		 * @param	params	[x, y]
		 * @param	isRelative	Use relative positions
		 */
		private static function pSmoothQuad(params:Array, isRelative:Boolean = false):void {
			var c:Point = (_prevCommand.toUpperCase() == "Q" || _prevCommand.toUpperCase() == "T")? GeomUtils.reflectPoint(_prevControl, _prevAnchor) : _prevAnchor;
			pQuad([c.x, c.y, params[0], params[1]], isRelative);
		}
		
		/**
		 * Close Path
		 */
		private static function pClose():void {
			_motifs.push(['L', [_initAnchor.x, _initAnchor.y]]);
		}
		
		/**
		 * Convert point position to absolute
		 */
		private static function toAbsolute(p:Point):void {
			p.x += _prevAnchor.x;
			p.y += _prevAnchor.y;
		}
		
		/**
		 * Convert point position to relative
		 */
		private static function toRelative(p:Point):void {
			p.x -= _prevAnchor.x;
			p.y -= _prevAnchor.y;
		}
		
		/**
		 * Convert X position to absolute
		 */
		private static function toAbsoluteX(x:Number):Number {
			return x + _prevAnchor.x;
		}
		
		/**
		 * Convert Y position to absolute
		 */
		private static function toAbsoluteY(y:Number):Number {
			return y + _prevAnchor.y;
		}
		
		static public function getWarnings():String { return _warnings; }
		
	}
	
}