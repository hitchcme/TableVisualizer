function [HRMINSEC,hr,min,sec] = sec2hms(sec)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
	HR = sec / 3600;
	[hr,min,sec] = utils.nav.dms(sec / 3600);

	sec = round(sec,6);
	HR = num2str(hr);
	MIN = num2str(min);
	SEC = num2str(floor(sec));
	%[abs(floor(sec)*10^6-sec*10^6),floor(sec)*10^6]
	US = num2str(abs(floor(sec)*10^6-sec*10^6));
	%dpos = strfind(US,'.')
	%size(US)
	%US = num2str(US(dpos+1:size(US,2)))
	%pause

	%US = num2str(round((sec - floor(sec) )*10^6))
	%US = num2str(   round( (sec - floor(sec)) * 10^6 )   )
	while size(US,2) < 6
		US = horzcat('0',US);
	end
	if hr < 10
		HR = horzcat('0',HR);
	end
	if min < 10
		MIN = horzcat('0',MIN);
	end
	if sec < 10
		SEC = horzcat('0',SEC);
	end
	% num2str seems to like to chop decimals, so heres a better solution
	SEC = horzcat(SEC,'.',US);
	
	HRMINSEC = horzcat(HR,':',MIN,':',SEC);
	while size(HRMINSEC,2) < 15
		HRMINSEC = horzcat(HRMINSEC,'0');
	end

end

