function deg = dms2deg(pol,deg,min,sec)
% Convert dms to degrees
% pol = -1 or 1 for negative or positive value

	% in support of a colon delimited time string
	% i.e.  'HHH:MM:SS.FFFFFFFFFFF......'
	if nargin == 1 & ischar(pol) & size(strfind(pol,':'),2) == 2
		DMS = str2double(utils.misc.strsplit(pol,':'));
		pol = (isnan(size(strfind(pol,'-'),1)/size(strfind(pol,'-'),1))*2)-1;
		deg = abs(DMS(1));
		min = abs(DMS(2));
		sec = abs(DMS(3));
		deg = pol * (deg + min/60 + sec/60/60);
	elseif nargin == 4
		deg = pol * (deg + min/60 + sec/60/60);
	else
		fprintf('invalid input');
	end
	
	
