function PhoneInfo () {

	this.phoneNumbers = {};

	this.sort_by = function(field, reverse, primer){
	
	   var key = function (x) {return primer ? primer(x[field]) : x[field]};
	
	   return function (a,b) {
	       var A = key(a), B = key(b);
	       //return ((A < B) ? -1 : (A > B) ? +1 : 0)) * [-1,1][+!!reverse];                  
			return (A < B ? -1 : (A > B ? 1 : 0)) * [1,-1][+!!reverse];
	   }
	}
	
	this.storePhoneInfo  = function(mLatitude, mLongitude, mParameters, phoneColor) {
		
		// Check if required parameters have been supplied
		if(typeof mLatitude == "undefined" || typeof mLongitude == "undefined") {
			return null;
		}
		
		var paramObject = null;
		
		if(typeof mParameters == "object") {
			paramObject = mParameters;
		}
	
		// If phone number is present, add number as unique index in an array with objects containing date and point
		if(paramObject != null) {
			if('Phone' in paramObject && ('Date' in paramObject)) {
				if(paramObject.Date != "") {
					if((paramObject.Phone in this.phoneNumbers)) {
						this.phoneNumbers[paramObject.Phone].pts.push({ point: [parseFloat(mLatitude), parseFloat(mLongitude)], date: paramObject.Date});
					} else {
						this.phoneNumbers[paramObject.Phone] = {};
						this.phoneNumbers[paramObject.Phone].pts = [{ point: [parseFloat(mLatitude), parseFloat(mLongitude)], date: paramObject.Date}];
						this.phoneNumbers[paramObject.Phone].color = phoneColor;
					}
				}
			}
		}
	}
	
	this.drawPolylines = function (map) {
		var polylines = [];
		var arrows = [];
		for(phone in this.phoneNumbers) {
			// Create temporary array to store all points of a certain phone number
			var tmpPoints = [];
			
			this.phoneNumbers[phone].pts.sort(this.sort_by('date', false, function(val) {								
				return new Date(Date.parse(val)).getTime();
			}));
			
			// Loop through all points for this phone number
			for(index in this.phoneNumbers[phone].pts) {
				tmpPoints.push(this.phoneNumbers[phone].pts[index].point);
			}
			
			var tmpColor = this.phoneNumbers[phone].color;	
			var polyOptions = {
			  	stroke:true,
			  	color: tmpColor,
			  	weight:2,
			  	opacity: 1      	
			};	
			var polyline = L.polyline(tmpPoints, polyOptions);	
//			polyline.setText('  ►  ', {repeat: true, attributes: {fill: 'red'}});	
			polyline.setText('   \u25BA   ', {repeat: true,
                                  offset: 4,
                                  attributes: {fill: tmpColor}});					
  			polylines.push(polyline); 	

/*  					  
 			L.extend(polyOptions,{fill: true, fillOpacity: 1});  			
			var arrowHead = L.polylineDecorator(polyline,{
			        patterns: [
			            {offset: 15, repeat: 75, symbol: L.Symbol.arrowHead({pixelSize: 12, polygon: true, pathOptions: polyOptions})}
			        ]}          
			);	
			arrows.push(arrowHead);	
*/				
		}

		
		var lineGroup = L.layerGroup(polylines).addTo(map);
//		var arrowGroup = L.layerGroup(arrows).addTo(map);
	};
}