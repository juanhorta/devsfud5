/**
 *
 *		SalesForce - Cloudmade Mashup
 *
 *		To display circle, call: AMap.plotCircle = function(mLatitude, mLongitude, mRadius, mIcon, mParameters)
 *			mIcon:			URL to Icon - String or null
 *			mParameters:	Object with content to display in InfoWindow - Object or null
 *
 */
 
 
 /**
  *
  *	Function to create a comparator sort an array of objects
  *	@param	field	{String}	Field name to sort on
  *	@param	reverse	{Boolean}	'true' to sort in DESC
  *	@param	primer	{function}	The function to convert the field value to a comparable value
  *	
  *	@author		Shishir Srivastava
  *	@date		30th October, 2012
  *
  */
var sort_by = function(field, reverse, primer){

   var key = function (x) {return primer ? primer(x[field]) : x[field]};

   return function (a,b) {
       var A = key(a), B = key(b);
       //return ((A < B) ? -1 : (A > B) ? +1 : 0)) * [-1,1][+!!reverse];                  
		return (A < B ? -1 : (A > B ? 1 : 0)) * [1,-1][+!!reverse];
   }
}



/**
 * Creates a point on the earth's surface at the supplied latitude / longitude
 *
 * @constructor
 * @param {Number} lat: latitude in numeric degrees
 * @param {Number} lon: longitude in numeric degrees
 * @param {Number} [rad=6371]: radius of earth if different value is required from standard 6,371km
 */
function LatLon(lat, lon, rad) {
  if (typeof(rad) == 'undefined') rad = 6371;  // earth's mean radius in km
  // only accept numbers or valid numeric strings
  this._lat = typeof(lat)=='number' ? lat : typeof(lat)=='string' && lat.trim()!='' ? +lat : NaN;
  this._lon = typeof(lat)=='number' ? lon : typeof(lon)=='string' && lon.trim()!='' ? +lon : NaN;
  this._radius = typeof(rad)=='number' ? rad : typeof(rad)=='string' && trim(lon)!='' ? +rad : NaN;
}

/**
 * Returns the destination point from this point having travelled the given distance (in km) on the 
 * given initial bearing (bearing may vary before destination is reached)
 *
 *   see http://williams.best.vwh.net/avform.htm#LL
 *
 * @param   {Number} brng: Initial bearing in degrees
 * @param   {Number} dist: Distance in km
 * @returns {LatLon} Destination point
 */
LatLon.prototype.destinationPoint = function(brng, dist) {
  dist = typeof(dist)=='number' ? dist : typeof(dist)=='string' && dist.trim()!='' ? +dist : NaN;
  dist = dist/this._radius;  // convert dist to angular distance in radians
  brng = brng.toRad();  // 
  var lat1 = this._lat.toRad(), lon1 = this._lon.toRad();

  var lat2 = Math.asin( Math.sin(lat1)*Math.cos(dist) + 
						Math.cos(lat1)*Math.sin(dist)*Math.cos(brng) );
  var lon2 = lon1 + Math.atan2(Math.sin(brng)*Math.sin(dist)*Math.cos(lat1), 
							   Math.cos(dist)-Math.sin(lat1)*Math.sin(lat2));
  lon2 = (lon2+3*Math.PI)%(2*Math.PI) - Math.PI;  // normalise to -180...+180

  return new LatLon(lat2.toDeg(), lon2.toDeg());
}

/**
 * Returns the latitude of this point; signed numeric degrees if no format, otherwise format & dp 
 * as per Geo.toLat()
 *
 * @param   {String} [format]: Return value as 'd', 'dm', 'dms'
 * @param   {Number} [dp=0|2|4]: No of decimal places to display
 * @returns {Number|String} Numeric degrees if no format specified, otherwise deg/min/sec
 *
 * @requires Geo
 */
LatLon.prototype.lat = function() {
  return this._lat;
}

/**
 * Returns the longitude of this point; signed numeric degrees if no format, otherwise format & dp 
 * as per Geo.toLon()
 *
 * @param   {String} [format]: Return value as 'd', 'dm', 'dms'
 * @param   {Number} [dp=0|2|4]: No of decimal places to display
 * @returns {Number|String} Numeric degrees if no format specified, otherwise deg/min/sec
 *
 * @requires Geo
 */
LatLon.prototype.lon = function() {
  return this._lon;
}

// ---- extend Number object with methods for converting degrees/radians

/** Converts numeric degrees to radians */
if (typeof(Number.prototype.toRad) === "undefined") {
  Number.prototype.toRad = function() {
	return this * Math.PI / 180;
  }
}

/** Converts radians to numeric (signed) degrees */
if (typeof(Number.prototype.toDeg) === "undefined") {
  Number.prototype.toDeg = function() {
	return this * 180 / Math.PI;
  }
}


/*
*
*   Cloudmade Map with marker and circle
*   @author:    Shishir Srivastava
*
*/






/*
*   Circle Object
*/
function ACircle(map, mLatitude, mLongitude, mRadius, mIcon, mParameters, mCircleParameters) {
	if(typeof mLatitude == "undefined" || typeof mLongitude == "undefined" || typeof mRadius == "undefined" || this.map == "undefined") {
		return null;
	}
	
	this._mLatitude = mLatitude;
	this._mLongitude = mLongitude;
	this._mRadius = mRadius;
	this._map = map;
	
	this._circle = null;
	this._marker = null;
	this._markerOptions = null;
	
	this._mIconUrl = "";
	
	if('defaultUrl' in AMap_config.icon) {
		this._mIconUrl = AMap_config.icon.defaultUrl;
	}
	
	this._infoWinContent = null;
	
	if(typeof mIcon != "undefined" && mIcon != null) {
		this._mIconUrl = mIcon;
	}
	
	this._mParameters = null;
	
	if(typeof mParameters == "object") {
		this._mParameters = mParameters;
	}
	
	this._circleParameters = null;
	//this._circleParameters = AMap_config.circle;
	this._circleParameters = {
		stroke: {
			color: "#00FF00",
			weight: 2,
			opacity: 0.75
		},
		fill: {
			color: "#00FF00",
			opacity: 0.2
		}
	};
	
	if(typeof mCircleParameters == "object") {
		/*if(typeof mCircleParameters.stroke != "undefined") {
			this._circleParameters.stroke.color = (typeof mCircleParameters.stroke.color != "undefined")?mCircleParameters.stroke.color:AMap_config.circle.stroke.color;
			this._circleParameters.stroke.weight = (typeof mCircleParameters.stroke.weight != "undefined")?mCircleParameters.stroke.weight:AMap_config.circle.stroke.weight;
			this._circleParameters.stroke.opacity = (typeof mCircleParameters.stroke.opacity != "undefined")?mCircleParameters.stroke.opacity:AMap_config.circle.stroke.opacity;
		}
		if(typeof mCircleParameters.fill != "undefined") {
			this._circleParameters.fill.color = (typeof mCircleParameters.fill.color != "undefined")?mCircleParameters.fill.color:AMap_config.circle.fill.color;
			this._circleParameters.fill.opacity = (typeof mCircleParameters.fill.opacity != "undefined")?mCircleParameters.fill.opacity:AMap_config.circle.fill.opacity;
		}*/
		if("stroke" in mCircleParameters) {
			if("color" in mCircleParameters.stroke) {
				this._circleParameters.stroke.color = mCircleParameters.stroke.color;
			}
			if("weight" in mCircleParameters.stroke) {
				this._circleParameters.stroke.weight = mCircleParameters.stroke.weight;
			}
			if("opacity" in mCircleParameters.stroke) {
				this._circleParameters.stroke.opacity = mCircleParameters.stroke.opacity;
			}
		}
		if("fill" in mCircleParameters) {
			if("color" in mCircleParameters.fill) {
				this._circleParameters.fill.color = mCircleParameters.fill.color;
			}
			if("opacity" in mCircleParameters.fill) {
				this._circleParameters.fill.opacity = mCircleParameters.fill.opacity;
			}
		}
	}
	
	this.createMarkerOptions();
}


/*
*   Function to calculate the pixel radius for current zoom level
*/
ACircle.prototype.calculatePixelRadius = function() {
	var latlng1 = new LatLon(this._mLatitude, this._mLongitude);
	var latlng2 = latlng1.destinationPoint(0, this._mRadius);   // bearing = 0
	
	var point1 = this._map.fromLatLngToDivPixel(new CM.LatLng(latlng1.lat(), latlng1.lon()));
	var point2 = this._map.fromLatLngToDivPixel(new CM.LatLng(latlng2.lat(), latlng2.lon()));
	
	// Use distance formula to calculate distance between 2 pixels
	// Distance = sq. root of ((x2-x1)^2 + (y2 - y1)^2)
	var distance = Math.ceil(Math.sqrt(Math.pow(point2.x - point1.x, 2) + Math.pow(point2.y - point1.y, 2)));
	
	return distance;
};


/*
*   Function to create the marker options - called once
*/
ACircle.prototype.createMarkerOptions = function() {
	this._markerOptions = {
		title: ""
	};
	
	if(this._mIconUrl != "") {
		this._markerOptions.icon = new CM.Icon();
		this._markerOptions.icon.image = this._mIconUrl;
		this._markerOptions.icon.iconSize = new CM.Size(AMap_config.icon.size.width, AMap_config.icon.size.height);
		this._markerOptions.icon.iconAnchor = new CM.Point(AMap_config.icon.anchorPoint.x, AMap_config.icon.anchorPoint.y);
	}
	
	// Create Marker Infowindow if mParameters is supplied
	if(this._mParameters != null) {
		this._infoWinContent = "";
		for(key in this._mParameters) {
			this._infoWinContent += "<p>" + key + ": " + this._mParameters[key] + "</p>";
		}
	}
};


/*
*   Function to create and draw the overlay on map
*/
ACircle.prototype.draw = function() {
	if(this._circle != null || this._marker != null) {
		this.clear();
	}
	
	// Draw the circle on map and place a marker
	this._circle = new CM.Circle(new CM.LatLng(this._mLatitude, this._mLongitude), this.calculatePixelRadius(), this._circleParameters.stroke.color, this._circleParameters.stroke.weight, this._circleParameters.stroke.opacity, this._circleParameters.fill.color, this._circleParameters.fill.opacity);
	
	this._map.addOverlay(this._circle);
	
	this._marker = new CM.Marker(new CM.LatLng(this._mLatitude, this._mLongitude), this._markerOptions);
	
	//var thisCircle = this;
	
	if(this._infoWinContent != null) {
		this._marker.bindInfoWindow(this._infoWinContent);
	}
	/*
	CM.Event.addListener(thisCircle._marker, 'click', function(latlng) {
		thisCircle._marker.openInfoWindow(thisCircle._infoWinContent);
	});*/
	
	this._map.addOverlay(this._marker);
};


/*
*   Function to remove the overlay from map
*/
ACircle.prototype.clear = function() {
	if(this._circle != null) {
		this._map.removeOverlay(this._circle);
		this._circle = null;
	}
	
	if(this._marker != null) {
		this._map.removeOverlay(this._marker);
		this._marker = null;
	}
};


/*
*   Main object
*/
var AMap = {
	map: null,
	cloudmade: null,
	circle: [],
	arrowLines: {},
	phoneNumbers: {}
};


/*
*   Function to initialize map
*/
AMap.initMap = function(mLatitude, mLongitude, mMapParameters) {
	var centerLat = AMap_config.defaultCenter.lat;
	var centerLng = AMap_config.defaultCenter.lng;
	var zoomVal = AMap_config.defaultZoomLevel;
	AMap.cloudmade = new CM.Tiles.CloudMade.Web({key: AMap_Cloudmade_API_Key});
	AMap.map = new CM.Map(AMap_config.mapContainer, AMap.cloudmade);
	AMap.map.setCenter(new CM.LatLng(centerLat, centerLng), zoomVal);
	AMap.map.addControl(new CM.LargeMapControl());
	AMap.map.addControl(new CM.ScaleControl());
	CM.Event.addListener(AMap.map, 'zoomend', AMap.zoomHandler);
	
	//@Author: Christian Anderson
	//@Date: 2013-01-08
	//A temporary fix for issue with map tiles not loading. see: https://github.com/Leaflet/Leaflet/issues/941
	if(AMap.map.getSize().width == 0) {
		AMap.map.checkResize();
		AMap.map.setCenter(new CM.LatLng(centerLat, centerLng), zoomVal);
	}
};


/*
*   Function to plot a circle with marker
*/
AMap.plotCircle = function(mLatitude, mLongitude, mRadius, mIcon, mParameters, mMapParameters, mCircleParameters) {
	
	// Check if required parameters have been supplied
	if(typeof mLatitude == "undefined" || typeof mLongitude == "undefined" || typeof mRadius == "undefined") {
		return null;
	}
	
	// Check if mIcon parameter has been supplied
	var customIcon = true;
	if(typeof mIcon == "undefined") {
		customIcon = false;
	}
	
	if(mIcon == "" || mIcon == null) {
		customIcon = false;
	}
	
	var paramObject = null;
	
	if(typeof mParameters == "object") {
		paramObject = mParameters;
	}
	
	var mapParameters = null;
	
	if(typeof mMapParameters == "object") {
		mapParameters = mMapParameters;
	}
	
	var circleParameters = null;
	
	if(typeof mCircleParameters == "object") {
		circleParameters = mCircleParameters;
	}
	
	// Convert radius from Meters to KM
	mRadius = mRadius / 1000;   
	
	// Initialize map if it hasn't been done already
	if(AMap.map == null) {
		AMap.initMap(mLatitude, mLongitude, mapParameters);
	}
	
	var aCircle = null;
	
	if(customIcon == false) {
		aCircle = new ACircle(AMap.map, mLatitude, mLongitude, mRadius, null, paramObject, circleParameters);
	} else {
		aCircle = new ACircle(AMap.map, mLatitude, mLongitude, mRadius, mIcon, paramObject, circleParameters);
	}
	
	AMap.circle.push(aCircle);
	
	AMap.refreshCircles();
	
	// If phone number is present, add number as unique index in an array with objects containing date and point
	if(paramObject != null) {
		if('Phone' in paramObject && ('Date' in paramObject)) {
			if(paramObject.Date != "") {
				if((paramObject.Phone in AMap.phoneNumbers)) {
					AMap.phoneNumbers[paramObject.Phone].push({ point: new CM.LatLng(mLatitude, mLongitude), date: paramObject.Date, mCircleParameters: mCircleParameters });
				} else {
					AMap.phoneNumbers[paramObject.Phone] = [ { point: new CM.LatLng(mLatitude, mLongitude), date: paramObject.Date, mCircleParameters: mCircleParameters } ];
				}
			}
		}
	}
};


/*
*   Function to plot a circle with marker if address is passed
*/
AMap.plotCircleAddress = function(mAddress, mRadius, mIcon, mParameters, mMapParameters, mCircleParameters) {
	
	// Geocode Address
	var geocoder = new CM.Geocoder(AMap_Cloudmade_API_Key);
	geocoder.getLocations(mAddress, function(response) {
		if(response.features.length < 1) {
			alert('Supplied address could not be found.');
			return;
		}
		
		var tmpCoords = response.features[0].centroid.coordinates;
		
		var mapParameters = null;
		
		if(typeof mMapParameters == "object") {
			mapParameters = mMapParameters;
		}
		
		var circleParameters = null;
		
		if(typeof mCircleParameters == "object") {
			circleParameters = mCircleParameters;
		}
		
		AMap.plotCircle(tmpCoords[0], tmpCoords[1], mRadius, mIcon, mParameters, mapParameters, circleParameters);
		
	});
};


/*
*   Draws all overlays
*/
AMap.refreshCircles = function() {
	// Call clear and draw for all circles
	for(index in AMap.circle) {
		AMap.circle[index].clear();
		AMap.circle[index].draw();
	}
};


/*
*   Zoom Changed handler
*/
AMap.zoomHandler = function() {
	// Refresh circles when zoom is changed
	AMap.refreshCircles();
};


/*
*	Sort through points and show arrows in right order
*/
AMap.createArrows = function() {
	// Run loop for every phone number
	for(phone in AMap.phoneNumbers) {
		// Create temporary array to store all points of a certain phone number
		var tmpPoints = [];
		
		AMap.phoneNumbers[phone].sort(sort_by('date', false, function(val) {
			
			
			return new Date(Date.parse(val)).getTime();
		}));
		
		// Loop through all points for this phone number
		for(index in AMap.phoneNumbers[phone]) {
			tmpPoints.push(AMap.phoneNumbers[phone][index].point);
		}
		
		var tmpColor = '#00FF00';
		if("stroke" in AMap.phoneNumbers[phone][index].mCircleParameters) {
			if("color" in AMap.phoneNumbers[phone][index].mCircleParameters.stroke) {
				tmpColor = AMap.phoneNumbers[phone][index].mCircleParameters.stroke.color;
			}
		}
		
		AMap.arrowLines[phone] = new CM.ArrowedPolyline(tmpPoints, tmpColor, 3, 0.75);
		AMap.map.addOverlay(AMap.arrowLines[phone]);
	}
};


/*
*   Shows all arrow lines
*/
AMap.showConnectors = function() {
	// Call show() for all arrows
	for(index in AMap.arrowLines) {
		AMap.arrowLines[index].show();
	}
};


/*
*   Hides all arrow lines
*/
AMap.hideConnectors = function() {
	// Call hide() for all arrows
	for(var index in AMap.arrowLines) {
		AMap.arrowLines[index].hide();
	}
};


/*
*	Event handler for checkbox control
*/
AMap.handleArrowVisibilityChange = function(checkbox) {
	setTimeout(function() {
		//display("Clicked, new value = " + cb.checked);
		if(checkbox.checked) {
			AMap.showConnectors();
		} else {
			AMap.hideConnectors();
		}
	}, 0);
}
