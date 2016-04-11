function Output = ZeroTinSec(Val)

	datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss.SSSSSS');
	
	HMS = regexprep(regexprep(cellstr(Val),':',' '),'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ','');
	HR = str2double(regexprep(HMS,' [0-9][0-9] [0-9][0-9].[0-9][0-9][0-9][0-9][0-9][0-9]',''));
	MIN =  str2double(regexprep(regexprep(HMS,' [0-9][0-9].[0-9][0-9][0-9][0-9][0-9][0-9]',''),'[0-9][0-9] ',''));
	SEC = str2double(regexprep(HMS,'[0-9][0-9] [0-9][0-9] ',''));

	SEC = ((utils.nav.dms2deg(1,0,MIN,SEC)*60)-min(MIN))*60;
	Output = SEC;
	%if iscellstr(Val) && size(Val,1) > 1
	%	for i = 1:1:size(Val,1)
	%		wv = strsplit(char(Val(i)));
	%		wv = strsplit(char(wv(2)),':');
	%		Val(i) = cellstr(wv(3));
	%	end
	%	
	%	Val = str2double(Val);
	%	T_Offset = min(Val);
	%	Output = Val - T_Offset;
	%	
	%else
	%	fprintf('Stop giving me bad inputs!');
	%end
	
		
	



end

