function [INTPATH] = build_INTPATHs(CF,CFPATH)
	
	
	if ispc
		DIRDELIM = '\';
	else
		DIRDELIM = '/';
	end
	if nargin < 2
		THISFILE = mfilename;
		THISDIR = mfilename('fullpath');
		THISDIR = THISDIR(1:end-size(THISFILE,2));
		%Fix THISDIR Variable for having selfcontained function file
		THISDIR = utils.files.GetFullPath(horzcat(THISDIR,'..',DIRDELIM,'..',DIRDELIM));
	else
		THISFILE = CF;
		THISDIR = CFPATH;
		THISDIR = THISDIR(1:end-size(THISFILE,2));
	end
    %This one from when function locted inside importer function files
    DWORKDIR = horzcat(THISDIR,'.tmp',DIRDELIM);
    
	% Key files for import
	TABLE1 = horzcat(DWORKDIR,'Table 1');
	DATSTORF = horzcat(DWORKDIR,'TABLES.mat');
	PATHSTORF = horzcat(DWORKDIR,'INTPATH.mat');
	PATHSTORF1 = horzcat(DWORKDIR,'MISSION.mat');
	
	ERRLOG = horzcat(DWORKDIR,'Error.log');
	SRCLOG = horzcat(DWORKDIR,'Source.log');
	
	% If the Data Work Directory doesn't exist
    % create it
	if ~exist(DWORKDIR, 'dir');
        mkdir(DWORKDIR);
	end

	if ispc
		fileattrib(DWORKDIR,'+h');
		% unnecessary for any *nix operating system
		% the leading '.' tells the operating system to hide it
	end

	RDRDIRS = dir(horzcat(DWORKDIR,'RDR*'));
	RDRDIRS1 = cellstr(char(RDRDIRS.name));

	if size(char(RDRDIRS1(1)),2) > 0
		RDRFILE = strcat(DWORKDIR,cellstr(char(RDRDIRS.name)),DIRDELIM,RDRDIRS1);
		RDRSRCLOG = strcat(DWORKDIR,cellstr(char(RDRDIRS.name)),DIRDELIM,'Source.log');
		RDRERRLOG = strcat(DWORKDIR,cellstr(char(RDRDIRS.name)),DIRDELIM,'Error.log');
	else
		RDRFILE = '';
	end
	
	INTPATH = struct('THISDIR',THISDIR);
	INTPATH.DATDIR = DWORKDIR;
	INTPATH.TABLES = DATSTORF;
	INTPATH.MISSION = PATHSTORF1;
	INTPATH.INTPATH = PATHSTORF;
	
	INTPATH.TABLE1 = struct('TABLE1',TABLE1,'SRCLOG',SRCLOG,'ERRLOG',ERRLOG);

	for i=1:size(RDRFILE,1)
		STR = RDRSRCLOG(i);
		ERRLOG = RDRERRLOG(i);
		SRCLOG = RDRSRCLOG(i);
		FILE = RDRFILE(i);
		STR = utils.misc.strsplit(char(regexprep(regexprep(regexprep(STR,DWORKDIR,''),'Source.log',''),'[\\\/]','')),'_');
		if ispc
            STRwv = char(STR(1));
            RSPinS = strfind(char(STR(1)),'RDR');
            STRSIZ = size(char(STR(1)),2);
            STRwv = STRwv(RSPinS:STRSIZ);
            STR(1) = cellstr(STRwv);
        end
		NEWSTRUCT = struct('FILE',FILE,'SRCLOG',SRCLOG,'ERRLOG',ERRLOG);
		%INTPATH.RDRX <- The String to go there
		RDR_entry = char(strcat(STR(1),STR(2)));
        
		PSHoIMP = char(STR(3));
        % The following doesn't work, unless it's in a directory with
        % underscores in it's name, soooo.... don't put it in a directory
        % with underscores.
        %just its in a directory with underscores in its name
        %if strfind(PSHoIMP,'RDR') > 1
        %    PSHoIMP = PSHoIMP(strfind(PSHoIMP,'RDR'):size(PSHoIMP,2));
        %end
		INTPATH.(RDR_entry).(PSHoIMP) = struct('FILE',FILE,'SRCLOG',SRCLOG,'ERRLOG',ERRLOG);
	end
	INTPATHPATH = horzcat(DWORKDIR,'INTPATH.mat');
	save(INTPATHPATH,'INTPATH');	