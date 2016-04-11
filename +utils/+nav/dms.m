function [DEG,MIN,SEC] = dms(deg)

	if deg < 0
		pol = -1;
		deg = abs(deg);
	else
		pol = 1;
	end
	
	DEG = floor(deg);
	remainder = deg - DEG;
	DEG = pol * DEG;
	
	MIN = floor(remainder*60);
	remainder = remainder - MIN/60;
	
	SEC = remainder*60*60;
	remainder = remainder - SEC/60/60;
	
	
	