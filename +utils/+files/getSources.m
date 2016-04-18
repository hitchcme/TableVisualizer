function SOURCES = getSources(PATHTOSRCLOG,Primary)

	if ~exist('Primary','var')
		Primary = false;
	end
	
	if exist(PATHTOSRCLOG, 'file')
		fid = fopen(PATHTOSRCLOG,'r');
		tline = fgetl(fid);
		
		if ~Primary
			while ischar(tline)
				if exist('SOURCES','var');
					SOURCES = {SOURCES;tline};
				else
					SOURCES = tline;
				end
				tline = fgetl(fid);
			end
		else
			SOURCES = tline;
		end
					
	end
	SOURCES = regexprep(SOURCES,'\\n','');
	%SOURCES(1) = [];
	
	

	
	
	