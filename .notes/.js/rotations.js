// rotation functions from js

	var rotateZ3D = function(theta) {
	   var sinTheta = sin(theta);
	   var cosTheta = cos(theta);
	   for (var n = 0; n < nodes.length; n++) {
		  var node = nodes[n];
		  var x = node[0];
		  var y = node[1];
		  node[0] = x * cosTheta - y * sinTheta;
		  node[1] = y * cosTheta + x * sinTheta;
	   }
	};
	var rotateX3D = function(theta) {
	   var sinTheta = sin(theta);
	   var cosTheta = cos(theta);
	   for (var n = 0; n < nodes.length; n++) {
		  var node = nodes[n];
		  var y = node[1];
		  var z = node[2];
		  node[1] = y * cosTheta - z * sinTheta;
		  node[2] = z * cosTheta + y * sinTheta;
	   }
	};
	var rotateY3D = function(theta) {
	   var sinTheta = sin(theta);
	   var cosTheta = cos(theta);
	   for (var n = 0; n < nodes.length; n++) {
		  var node = nodes[n];
		  var x = node[0];
		  var z = node[2];
		  node[0] = x * cosTheta + z * sinTheta;
		  node[2] = z * cosTheta - x * sinTheta;
	   }
	};
