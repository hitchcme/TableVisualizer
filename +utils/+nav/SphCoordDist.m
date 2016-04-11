function [Rh,By,angle] = SphCoordDist(lat1,lng1,lat2,lng2)
	
	dlat = lat2 - lat1;

	% Assuming a sphere.  Imagine an imaginary sphere containing planet
	% Earth, and compensate with location based altitude corrections.
	EARTHRadius = (360 * 60) / (2 * pi); % (nMi)

	% Vector style vars
	lat1r = utils.nav.degtorad(lat1);
	lat2r = utils.nav.degtorad(lat2);
	lng1r = utils.nav.degtorad(lng1);
	lng2r = utils.nav.degtorad(lng2);
	
	x1 = EARTHRadius .* cos(lat1r) .* cos(lng1r);
	y1 = EARTHRadius .* cos(lat1r) .* sin(lng1r);
	z1 = EARTHRadius .* sin(lat1r);
	
	x2 = EARTHRadius .* cos(lat2r) .* cos(lng2r);
	y2 = EARTHRadius .* cos(lat2r) .* sin(lng2r);
	z2 = EARTHRadius .* sin(lat2r);
	
	c = sqrt( (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2 );
	C = utils.nav.radtodeg(acos((EARTHRadius^2 - 0.5 * c^2)/(EARTHRadius^2)));
	angle = C;
	Rh = 60 * C;
	
	Dlat = dlat * 60;
	
	if lng1 == lng2
		By = 0;
	else
		By = utils.nav.radtodeg(acos(Dlat/Rh));
	end
	
	By = 90 - utils.nav.radtodeg(atan2(cos(lat1r)*sin(lat2r)-sin(lat1r)*cos(lat2r)*cos(lng2r-lng1r),... 
		sin(lng2r-lng1r)*cos(lat2r)));

	By = mod(By + 360, 360);

end