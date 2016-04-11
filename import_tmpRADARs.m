function [VALID,MISSION_ID,RDRNUM,relPOS,TABLES] = import_tmpRADARs()
% VALID => Valid File
% RDRNUM => RADAR Number
% relPOS => RADAR Position with respect to test subject
% TABLE1_RDR => Radar Measurement table, using 'TABLE1_*' to keep the table
%				variables similar.

	% Where am I operating from?
	% Where's the data directory
	
    
	%[MISSION_ID,RDRNUM,TYPE] = GET_RDR_Info(wholepathfilename);
	%MYRDRFILENAME = char(strcat('RDR','_',num2str(RDRNUM),'_',TYPE));
	%[THISDIR,DWORKDIR,PATHTOMYFILE,PATHTOERRLOG,PATHTOSRCLOG] = buildtmppath(MYRDRFILENAME);
	
	% No input detected

        %[FileName,PathName,FilterIndex] = uigetfile('*.asc');
		THISFILE = mfilename;
		THISDIR = mfilename('fullpath');
		THISDIR = THISDIR(1:end-size(THISFILE,2));
		DWORKDIR = horzcat(THISDIR,'.tmp');
		wholepathfilename = strsplit(ls(horzcat(DWORKDIR,'/RDR*/RDR*')),'\n');
		SRCLOG = strsplit(ls(horzcat(DWORKDIR,'/RDR*/Source.log')),'\n');
		wholepathfilename(size(wholepathfilename,2)) = [];
		SRCLOG(size(SRCLOG,2)) = [];
        % File was selected, build the path to that file
		if size(wholepathfilename,2)
			% The shit should be good to go!
			% But.... try deleting all the Radar Files in ./tmp, and see
			% what it comes up with.... later, not now!

		% File not selected
		else
            VALID = false;
			MISSION_ID = '';
			RDRNUM = NaN;
			relPOS = [NaN,NaN,NaN];
			TABLE1_RDR = table(NaN,NaN,NaN,NaN);
			TABLE1_RDR.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity'};
			return

		end
    
	for i=1:size(wholepathfilename,2)
		wholepathfilename_wv = char(cellstr(wholepathfilename(i)));
		SRCLOG_wv = char(SRCLOG(i));
		fid = fopen(SRCLOG_wv);
		tline = fgetl(fid);
		fclose(fid);
		wholepathfilename_wv = tline;
		clear TABLE_RDR_wv
		[VALID,MISSION_ID,RDRNUM,relPOS,TABLES] = import_TableRADAR(wholepathfilename_wv);
		%if exist('TABLE_RDR','var')
	%		TABLE_RDR = [TABLE_RDR;TABLE_RDR_wv];
	%	else
	%		TABLE_RDR = TABLE_RDR_wv;
	%	end

	end










function Coordinate = ProcessCoordFromRead(linestr)
	m_to_ft = 3.2808398950131;
	
	POS = utils.misc.strsplit(char(linestr),':');
	POS = char(POS(2));
	if Match(POS,'m')
		MULTIPLIER = m_to_ft;
	elseif Match(POS,'ft')
		MULTIPLIER = 1;
	end
	POS = regexprep(char(POS),'[A-Z]','');
	Coordinate = str2double(regexprep(char(POS),'[a-z]',''))*MULTIPLIER;


function IsInCorrMissionDir = Check_MID_with_ParentDir(MISSION_ID,wholepathfilename)
	
	% use the matrix with a comma for an or
	% so if strfind finds nothing, the second value goes to the first
	% position in the matrix or array... whatever it is....
	IsInCorrMissionDir = [logical(size(strfind(wholepathfilename,MISSION_ID),2) >= 2),false];
	IsInCorrMissionDir = IsInCorrMissionDir(1);

	
	
function [MISSION_ID,RDRNUM,TYPE] = GET_RDR_Info(wholepathfilename)
	if ispc
		MRT = utils.misc.strsplit(wholepathfilename,'\');
		MRT = utils.misc.strsplit(char(regexprep(MRT(size(MRT,2)),'.asc','')),' ');
	else
		MRT = utils.misc.strsplit(wholepathfilename,'/');
		MRT = utils.misc.strsplit(char(regexprep(MRT(size(MRT,2)),'.asc','')),' ');
	end
	MISSION_ID = MRT(1);
	RDRNUM = str2double(regexprep(regexprep(MRT(2),'[A-Z]',''),'[a-z]',''));
	TYPE = upper(MRT(3));
	
	
	
function [PATHTOMYRAS,PATHTOERRLOG,PATHTOSRCLOG] = builddatpaths(MYRDRFILENAME)
    if ispc
        PATHTOMYRASC = horzcat(DWORKDIR,'\',MYRDRFILENAME);
		PATHTOERRLOG = horzcat(DWORKDIR,'\','Error.log');
		PATHTOSRCLOG = horzcat(DWORKDIR,'\','Source.log');
    elseif isunix
        PATHTOMYRASC = horzcat(DWORKDIR,'/',MYRDRFILENAME)
		PATHTOERRLOG = horzcat(DWORKDIR,'/','Error.log');
		PATHTOSRCLOG = horzcat(DWORKDIR,'/','Source.log');
	end


function [THISDIR,DWORKDIR,PATHTOMYFILE,PATHTOERRLOG,PATHTOSRCLOG] = 	buildtmppath(MYRDRFILENAME)
	THISFILE = mfilename;
    THISDIR = mfilename('fullpath');
    THISDIR = THISDIR(1:end-size(THISFILE,2));
    DWORKDIR = horzcat(THISDIR,'.tmp');
	% If the Data Work Directory doesn't exist
    % create it
	if ~exist(DWORKDIR, 'dir');
        mkdir(DWORKDIR);
	end
	
	if ispc
		fileattrib(DWORKDIR,'+h');
		DWORKDIR = horzcat(DWORKDIR,'\',MYRDRFILENAME)
		PATHTOMYFILE = horzcat(DWORKDIR,'\',MYRDRFILENAME);
		PATHTOERRLOG = horzcat(DWORKDIR,'\','Error.log');
		PATHTOSRCLOG = horzcat(DWORKDIR,'\','Source.log');
	else
		DWORKDIR = horzcat(DWORKDIR,'/',MYRDRFILENAME)
		PATHTOMYFILE = horzcat(DWORKDIR,'/',MYRDRFILENAME)
		PATHTOERRLOG = horzcat(DWORKDIR,'/','Error.log');
		PATHTOSRCLOG = horzcat(DWORKDIR,'/','Source.log');
	end
	
	if ~exist(DWORKDIR, 'dir');
		mkdir(DWORKDIR);
	end

	

	
	
	
function [MISSION_ID,RDRn] = Get_MID_AndRDRn_byFullName(wholepathfilename)

	if ispc
		LDSP = strfind(wholepathfilename,'\'); LDSP = LDSP(size(LDSP,2));
	else
		LDSP = strfind(wholepathfilename,'/'); LDSP = LDSP(size(LDSP,2));
	end
	STR = utils.misc.strsplit(wholepathfilename(LDSP:size(wholepathfilename,2)),' ');
	
	MISSION_ID = regexprep(STR(1),'/','');
	MISSION_ID = regexprep(MISSION_ID,'\','');
	MISSION_ID = regexprep(MISSION_ID,'\\','');
	RDRn = regexprep(STR(2),'[a-z]','');
	RDRn = floor(str2double(regexprep(RDRn,'[A-Z]','')));
	
	
function nmatch=nMatch(string,mstring)
		% Just like above		
        nmatch = [logical(strfind(string,mstring)),true];
        nmatch = nmatch(1);
        
        
function match=Match(string,mstring)
		% Just like above too...
        match = [logical(strfind(string,mstring)),false];
        match = match(1);