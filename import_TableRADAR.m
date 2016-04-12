function [VALID,TABLES,INTPATH,RFK] = import_TableRADAR(wholepathfilename);
% This function will grab a Table1, if there is no TABLES.TABLE1, and
% run import_Table1(), after it finds the Mission Path.
% if TABLES.TABLE1 is made, then TABLES.RADAR{NUM}.TS will be offset by
% the value of the TABLES.TABLE1.BW.TS(1) (Launch Point)
	if ispc
		DIRDELIM = '\';
	else
		DIRDELIM = '/';
	end
	
	
	% Every file is innocent until proven guilty!
    VALID = 1;
	
	INTPATH = build_INTPATHs();
	TABLES = load_TABLESmat(INTPATH.TABLES);
	saveStructs(INTPATH,TABLES);

	% No input detected
    if nargin == 0
        [FileName,PathName,FilterIndex] = uigetfile('*.asc');
    
        % File was selected, build the path to that file
        if logical(FileName(1) > 0) && logical(PathName(1) > 0) && logical(FilterIndex(1) > 0)
            wholepathfilename = horzcat(PathName,FileName);

		% File not selected
		else
            VALID = false;
			MISSION_ID = '';
			RDRNUM = NaN;
			relPOS = [NaN,NaN,NaN];
			TABLE1_RDR = table(NaN,NaN);
			TABLE1_RDR.Properties.VariableNames = {'Time' 'Velocity'};
            RFK = {'','',''};
			return

        end
    
    % Skip the whole GUI getfile thing, an input was given!
	% This person knows what they want!
    else
        wholepathfilename = utils.files.GetFullPath(wholepathfilename);
	end


	infileexists = logical(exist(wholepathfilename, 'file'));
	[MPATH, MISSION_ID, RDRNUM, TYPE, MYRDRFILENAME] = GET_RDR_Info(wholepathfilename);
	[TABLES] = PullMission(INTPATH,MISSION_ID);
	[TABLES] = Check_MIDandMPATH(INTPATH,TABLES,MPATH,MISSION_ID);
	%TABLES.MPATH = MPATH
	PATHTOMYFILE = horzcat(INTPATH.DATDIR,MYRDRFILENAME);
	[INTPATH,IPFIELD,IPSUBFIELD] = ChPATHinINTPATH(INTPATH,MYRDRFILENAME);
	PATHTOMYFILE = horzcat(INTPATH.DATDIR,MYRDRFILENAME,DIRDELIM,MYRDRFILENAME);

	% Make sure my file isnt the input
	NotmyFile = nMatch(wholepathfilename,PATHTOMYFILE);

	% it's not my file and the input file does exist
	% so we can replace my file in my directory
	% with the input file
	YESREPLACE = NotmyFile & infileexists;
	
	if YESREPLACE
		copyfile(wholepathfilename, PATHTOMYFILE,'f');
		saveStructs(INTPATH,TABLES);
	end
	
	% Rebuild INTPATH, because we should have something
    %INTPATH = build_INTPATHs();

	if logical(exist(PATHTOMYFILE, 'file'))
		% keep .tmp hidden!
		if NotmyFile
			WPFN = wholepathfilename;
		else
			% gets only the primary source path from the .tmp/Source.log
			WPFN = utils.getSources(PATHTOSRCLOG,true);
			wholepathfilename = WPFN;
		end
	
	import java.io.*;
	T1f = dir(wholepathfilename);
	moddate = T1f.date();
	moddate1 = utils.misc.strsplit(moddate,' ');
	moddate1 = moddate1(1);
	moddate = utils.misc.strsplit(regexprep(moddate,'-',' '));
	moddate = strtrim(moddate(3));

	%[MISSION_ID,RDRNUM] = Get_MID_AndRDRn_byFullName(wholepathfilename);
	if exist('MISSION_ID','var')
		IsInCorrMissionDir = Check_MID_with_ParentDir(MISSION_ID,wholepathfilename);
	else
		'File Incorrectly Named'
		return
	end

	if exist('IsInCorrMissionDir','var')
		if ~IsInCorrMissionDir
			'File Not in Correct Parent Directory'
			return
		end
	end
	
	%log the path to the selected Table 1 to Source.log
	utils.misc.logit(1,INTPATH.(IPFIELD).(IPSUBFIELD).SRCLOG,WPFN,false,false);

clear fid tline FMTLin_Str FMTSLin_Str TABLE1_BWs;

fid = fopen(INTPATH.(IPFIELD).(IPSUBFIELD).FILE);

WPFNForLog = WPFN;

if size(WPFN,2) >= 60 && size(WPFN,2) < 120
	WPFNForLog = horzcat(WPFN(1:60),'\n\t',WPFN(61:size(WPFN,2)));
elseif size(WPFN,2) >= 120
	WPFNForLog = horzcat(WPFN(1:60),'\n\t',WPFN(61:120),'\n\t',WPFN(121:size(WPFN,2)));
end

utils.misc.logit(1,INTPATH.(IPFIELD).(IPSUBFIELD).ERRLOG,horzcat('New Import\n\t',WPFNForLog),false,true);
tline = fgetl(fid);
which_line_am_I_on = 0;
LookAtOtherLineTypes = 0;
TABLE_wv = {0,0,0};
%TABLE_wv = cell2table(TABLE_wv);
i = 1;
	while ischar(tline)
		linestr = regexprep(utils.misc.strsplit(tline,','),' ','');

		if Match(tline,'Local X:')
			if ~exist('relPOS','var')
				relPOS(1) = ProcessCoordFromRead(linestr);
			else
				relPOS(1) = relPOS(1)+ProcessCoordFromRead(linestr);
			end
			
		elseif Match(tline,'Local Y:')
			if ~exist('relPOS','var')
				relPOS(2) = ProcessCoordFromRead(linestr);
			elseif size(relPOS,2) < 2
				relPOS(2) = ProcessCoordFromRead(linestr);
			else
				relPOS(2) = relPOS(2)+ProcessCoordFromRead(linestr);
			end
			
		elseif Match(tline,'Local Z:')
			if ~exist('relPOS','var')
				relPOS(3) = ProcessCoordFromRead(linestr);
			elseif size(relPOS,2) < 3
				relPOS(3) = ProcessCoordFromRead(linestr);
			else
				relPOS(3) = relPOS(3)+ProcessCoordFromRead(linestr);
			end

		elseif Match(tline,'Mission')
			%Mission ID Light Switch.
			%	Found Mission, read the next line to get the ID
			tline = fgetl(fid);
			tline = upper(tline);

			if Match(tline,'ID:')
				THISMID = regexprep(regexprep(regexprep(regexprep(tline,'[A-Z][A-Z][A-Z][0-9]',''),'[A-Z][A-Z]:',''),' ',''),'\t','');
				
				%[MISSION_ID,TABLES] = Check_n_fix_MID(THISMID,MISSION_ID,TABLES,INTPATH.TABLES);
			end
			
			
			
		
		elseif Match(tline,'File created')
			tline = regexprep(strsplit(tline(strfind(tline,'on')+2:size(tline,2)),'/'),' ','');
			if size(tline(2),1) < 2
				tline(2) = strcat(cellstr('0'),tline(2));
			end
			Mos = {'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec'};
			tline(1) = Mos(str2double(tline(1)));
			moddate1 = strcat(tline(2),'-',tline(1),'-',tline(3));
			
		elseif logical(size(linestr,2) == 6)
			if i == 1
				
				HEADERS = linestr;

				if Match(char(HEADERS(1)),'Time_UTC_int') && Match(char(HEADERS(2)),'Time_UTC_ms') && ...
				   Match(char(HEADERS(4)),'V_rad_mea')
			   
					HEADERS(1) = cellstr('Time');
					HEADERS(2) = cellstr('Velocity');
					HEADERS(3:6) = [];
					
				else
					% fail on 6 columns of data, but header Strings didn't match
					VALID = 0;
					MISSION_ID = '';
					RDRNUM = 0;
					relPOS = [0, 0, 0];
					TABLE1_RDR = table(0,0);
					return
				end
				
				%TABLE_wv.Properties.VariableNames = linestr
				
			elseif i == 2
				%The Unit specs could be used later maybe, if one wanted to
				%convert to different units, or.... maybe a file for some
				%reason was in the wrong units, not that feet is
				%necessarily the correct one
				%tline
				
			elseif i == 3
				linestr(1) = regexprep(linestr(1),'\.000000','');
				linestr(1) = regexprep(linestr(1),'\-','');
				linestr(2) = regexprep(linestr(2),'0\.','.');
				linestr(6) = regexprep(linestr(6),'0\.','.');
				if size(TABLE_wv,1) == 1
					%&& TABLE_wv(1) == 0 && TABLE_wv(2) == 0 && TABLE_wv(3) == 0
					linestr1 = linestr;
					sec1 = horzcat(char(linestr1(1)),char('.000000'));
				 	sec1 = str2double(sec1);
					[HRMINSEC1,~,~,~] = utils.nav.sec2hms(sec1);
					linestr1(2) = cellstr(horzcat(char(moddate1),' ',HRMINSEC1));
					linestr1(1) = [];
					linestr1(2) = [];
					linestr1(3:4) = [];
					linestr1(2) = cellstr('0');
					linestr1 = horzcat(MYRDRFILENAME,linestr1);
					TABLE_wv = [TABLE_wv;linestr1];
				end
				sec = horzcat(char(linestr(1)),char(linestr(2)));
				sec = str2double(sec);
				
				[HRMINSEC,~,~,~] = utils.nav.sec2hms(sec);
				linestr(2) = cellstr(horzcat(char(moddate1),' ',HRMINSEC));
				linestr(1) = [];
				linestr(2) = [];
				linestr(3:4) = [];
				% Tack on the name of our file copy name
				linestr = horzcat(MYRDRFILENAME,linestr);
				TABLE_wv = [TABLE_wv;linestr];
				
			end
			
			if i < 3
				i = i + 1;
			end
		end
		tline = fgetl(fid);

	end
	
	TABLE_wv(1,:) = [];
	TABLE1_RDR = cell2table(cellstr(TABLE_wv));
	TABLE1_RDR.Var2 = datetime(TABLE1_RDR.Var2,'InputFormat','dd-MMM-yy HH:mm:ss.SSSSSS')+(1/24/60/60/10000000000000);
	TABLE1_RDR.Var3 = str2double(TABLE1_RDR.Var3);
	TABLE1_RDR.Properties.VariableNames = {'Function' 'Time' 'Velocity'};


	%TABLE1_RDR.TS = [0;TABLE1_RDR.TS(1:size(TABLE1_RDR.TS)-1)+TABLE1_RDR.TS(2:size(TABLE1_RDR.TS))]

	TABLE1_RDR = utils.math.solve_P_from_Vt(TABLE1_RDR);
	
	%save(INTPATH.TABLES,'TABLES')
	
	TBL1MPATH = horzcat(TABLES.MPATH,'TP',DIRDELIM,TABLES.MID,'TABLE1.txt');

	if [cell2mat(strfind(fieldnames(TABLES),'TABLE1')),0]
		TABLE1_RDR.TS = TABLE1_RDR.TS + TABLES.TABLE1.BW.TS(1);
	elseif exist(TBL1MPATH,'file')
		[~,TABLES,INTPATH] = import_Table1(TBL1MPATH);
		TABLE1_RDR.TS = TABLE1_RDR.TS + TABLES.TABLE1.BW.TS(1);
		% Because Table1 doesn't have a year, except by the mod/creation
		% date, and the RADAR file does, and sometimes files get edited.
		TOffSet = round(datenum(TABLE1_RDR.Time(1)) - datenum(TABLES.TABLE1.BW.DateTime(1)));
		TABLE1_RDR.Time = TABLE1_RDR.Time - TOffSet;
		TABLE1_RDR.DateTime = TABLE1_RDR.Time;
		TABLE1_RDR.Time = utils.nav.ZeroTinSec(TABLE1_RDR.Time);
	end
	%if we still don't have a TABLES variable, then just create
	if ~exist('TABLES','var')
		TABLES = struct([]);
	end
	
	
	TABLE1_RDR.TS = round(TABLE1_RDR.TS,3);
	%TABLE1_RDR = [TABLE1_RDR(:,1) TABLE1_RDR(:,4) TABLE1_RDR(:,2) TABLE1_RDR(:,3)];
		


	if exist('MISSION_ID','var') && exist('RDRNUM','var') && exist('relPOS','var') && exist('TABLE1_RDR','var')
		VALID = true;
	else
		VALID = false;
	end
	save(INTPATH.TABLES,'TABLES');

	RDRNUMstr = strcat('RDR',num2str(RDRNUM));

	if cell2mat(strfind(fieldnames(TABLES),RDRNUMstr))
		RADAR = TABLES.(RDRNUMstr);
	end
	
	RADAR.(char(TYPE)) = TABLE1_RDR;
	relPOS(1) = round(relPOS(1)+TABLE1_RDR.TS(1),3);
	relPOS(2) = round(relPOS(2),3);
	relPOS(3) = round(relPOS(3),3);
	RADAR.POS = table(relPOS(1),round(relPOS(3),3),round(relPOS(2),3));
	RADAR.POS.Properties.VariableNames = {'TS' 'Offset' 'Altitude'};
	
	if sum(ismember(fieldnames(TABLES),'RADAR'))
	'there is a RADAR field';
	
		
		if size(TABLES.RADAR,1) >= RDRNUM
			'RADAR field is greater than or equal to rdrnum';
			if ismember(TYPE,'IMPACT')
				'current file is an impact file';
				STR = 'PUSHER';
			elseif ismember(TYPE,'PUSHER')
				'current file is a pusher file';
				STR = 'IMPACT';
			else
				STR = '';
			end
			if ~isempty(TABLES.RADAR{RDRNUM})
				'RADAR{NUM} is not empty';
				sum(ismember(fieldnames(TABLES.RADAR{RDRNUM}),STR));
				if sum(ismember(fieldnames(TABLES.RADAR{RDRNUM}),STR))
					RADAR.(STR) = TABLES.RADAR{RDRNUM}.(STR);
				end
			end
		end
	end
	
	RADAR.POS = table(relPOS(1),round(relPOS(3),3),round(relPOS(2),3));
	RADAR.POS.Properties.VariableNames = {'TS' 'Offset' 'Altitude'};
	
	%TABLES.RADAR{RDRNUM}.(char(TYPE)) = RADAR;
	TABLES.RADAR{RDRNUM} = RADAR;
	%TABLES.RADAR{RDRNUM}.POS = TABLES.RADAR{RDRNUM}.POS
	%Because I like a vertical RADAR listing instead of horizontal one.
	if size(TABLES.RADAR,2) > 1
		TABLES.RADAR = transpose(TABLES.RADAR);
	end
	
	%[ TABLES ] = utils.misc.enumRADARs(TABLES);

	
	save(INTPATH.TABLES,'TABLES');
	save(INTPATH.INTPATH,'INTPATH');
	
	if exist(INTPATH.MISSION,'file')
		load(INTPATH.MISSION,'MISSION');
	end
	Parent_MISSION = utils.misc.strsplit(TABLES.MID,'-');
	Parent_MISSION = char(cellstr(strcat('M_',Parent_MISSION(1))));
	Child_MISSION = utils.misc.strsplit(TABLES.MID,'-');
	Child_MISSION = char(Child_MISSION(2));
	MISSION.(Parent_MISSION).(Child_MISSION) = TABLES;
	save(INTPATH.MISSION,'MISSION');

else
    'I cant find any file here or there';
	end
	
	RFK = regexprep(utils.misc.strsplit(char(TABLE1_RDR.Function(1)),'_'),'RDR','RADAR');


function [TABLES] = PullMission(INTPATH,MID)
	MIDStr = utils.misc.strsplit(char(MID),'-');
	ParentMission = strcat('M_',MIDStr(1));
	ChildMission = MIDStr(2);
	load(INTPATH.MISSION,'MISSION');
	if sum(cell2mat(strfind(fieldnames(MISSION),ParentMission)))
		if sum(cell2mat(strfind(fieldnames(MISSION.(char(ParentMission))),ChildMission)))
			TABLES = MISSION.(char(ParentMission)).(char(ChildMission));
		else
			TABLES = struct('MID',MID);
		end
	else
		TABLES = struct('MID',MID);
	end
	save(INTPATH.TABLES,'TABLES');
	
	

function TABLES = load_TABLESmat(TABLESPATH)
	if exist(TABLESPATH,'file')
		load(TABLESPATH);
		cell2mat(strfind(fieldnames(TABLES),'MPATH'));
		cell2mat(strfind(fieldnames(TABLES),'MID'));
		if ~cell2mat(strfind(fieldnames(TABLES),'MPATH'))
			TABLES.MPATH = 'NONE';
		end
		if ~cell2mat(strfind(fieldnames(TABLES),'MID'))
			TABLES.MID = 'NONE';
		end
	else
		TABLES.MPATH = 'NONE';
		TABLES.MID = 'NONE';
		save(TABLESPATH,'TABLES');
	end

	
function saveStructs(INTPATH,TABLES)
	save(INTPATH.TABLES,'TABLES');
	save(INTPATH.INTPATH,'INTPATH');
	
	

function [INTPATH,INTPATHentry,INTPATHentry1] = ChPATHinINTPATH(INTPATH,MYRDRFILENAME)
	if ispc
		DIRDELIM = '\';
	else
		DIRDELIM = '/';
	end
	INTPATHentry = utils.misc.strsplit(MYRDRFILENAME,'_');
	INTPATHentry = char(strcat(INTPATHentry(1),INTPATHentry(2)));
	INTPATHentry1 = utils.misc.strsplit(MYRDRFILENAME,'_');
	INTPATHentry1 = char(INTPATHentry1(3));
	
	DIRECTORY = horzcat(INTPATH.DATDIR,MYRDRFILENAME);
	if ~exist(DIRECTORY,'dir')
		mkdir(DIRECTORY);
	end
	FILE = horzcat(DIRECTORY,DIRDELIM,MYRDRFILENAME);
	SRCLOG = horzcat(DIRECTORY,DIRDELIM,'Source.log');
	ERRLOG = horzcat(DIRECTORY,DIRDELIM,'Error.log');
	
	INTPATH.(INTPATHentry).(INTPATHentry1) = struct('FILE',FILE,'SRCLOG',SRCLOG,'ERRLOG',ERRLOG);
	

	
function [INTPATH] = build_INTPATHs(DIRDELIM)

	if ispc
		DIRDELIM = '\';
	else
		DIRDELIM = '/';
	end

	THISFILE = mfilename;
    THISDIR = mfilename('fullpath');
    THISDIR = THISDIR(1:end-size(THISFILE,2));
    DWORKDIR = horzcat(THISDIR,'.tmp',DIRDELIM);

	% Key files for import
	TABLE1 = horzcat(DWORKDIR,'Table 1');
	DATSTORF = horzcat(DWORKDIR,'TABLES.mat');
	PATHSTORF = horzcat(DWORKDIR,'INTPATH.mat');
	PATHTOMmat = horzcat(DWORKDIR,'MISSION.mat');
	if exist(PATHSTORF,'file')
		load(PATHSTORF,'INTPATH');
	end
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
	INTPATH.INTPATH = PATHSTORF;
	INTPATH.MISSION = PATHTOMmat;
	
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
		%INTPATH.RDRX.IMPACT or INTPATH.RDRX.PUSHER
		PSHoIMP = char(STR(3));
		INTPATH.(RDR_entry).(PSHoIMP) = struct('FILE',FILE,'SRCLOG',SRCLOG,'ERRLOG',ERRLOG);
	end
	INTPATHPATH = horzcat(DWORKDIR,'INTPATH.mat');
	save(INTPATHPATH,'INTPATH');


function Coordinate = ProcessCoordFromRead(linestr)
	m_to_ft = 3.2808398950131;
	
	POS = utils.misc.strsplit(char(linestr),':');
	POS = POS(2);
	if Match(char(POS),'m')
		MULTIPLIER = m_to_ft;
	elseif Match(POS,'ft')
		MULTIPLIER = 1;
	end
	POS = str2double(regexprep(regexprep(POS,'[A-Z]',''),'[a-z]',''));
	Coordinate = round(POS*MULTIPLIER,3);


function [MISSION_ID,TABLES] = Check_n_fix_MID(THISMID,MISSION_ID,TABLES,TmatP)

	THISMID
	MISSION_ID
	
	if Match(THISMID,MISSION_ID) && Match(THISMID,TABLES.MID)
	%'Yay, The Mission ID matches the Mission ID!!!!'
		save(TmatP,'TABLES');
	else
	%'Ooh, This Mission ID isnt correct....'
		
		%delete(TmatP);
		MID_wv = TABLES.MID
		MPATH_wv = TABLES.MPATH
		TABLES.MID = THISMID
		TABLES.MPATH = regexprep(MPATH_wv,'[0-9][0-9][A-Z]-[A-Z][0-9]',THISMID)
		%TABLES = struct('MID',THISMID);
	end

function [TABLES] = Check_MIDandMPATH(INTPATH,TABLES,MPATH,MISSION_ID)
	STR = fieldnames(TABLES);
	STR = cellstr(char(STR));
	MPATHM = strfind(STR,'MPATH');
	MPATHM = sum(logical(cell2mat([MPATHM(~cellfun('isempty',MPATHM)),0])));
	MIDM = strfind(STR,'MID');
	MIDM = sum(logical(cell2mat([MIDM(~cellfun('isempty',MIDM)),0])));
	if or(~MIDM,~MPATHM)
        try
            rmdir(horzcat(INTPATH.DATDIR,'RDR*'),'s');
        catch e
            '';
        end
            TABLES = struct('MPATH',MPATH,'MID',MISSION_ID);

	else
		MPATHM = [strfind(TABLES.MID,MISSION_ID),0];
		MIDM = [strfind(TABLES.MPATH,MPATH),0];
		if or(~MIDM,~MPATHM)
            try 
                rmdir(horzcat(INTPATH.DATDIR,'RDR*'),'s');
            catch e
                '';
            end
			TABLES = struct('MPATH',MPATH,'MID',MISSION_ID);
		end
	end
	
	
	

function IsInCorrMissionDir = Check_MID_with_ParentDir(MISSION_ID,wholepathfilename)
	
	% use the matrix with a comma for an or
	% so if strfind finds nothing, the second value goes to the first
	% position in the matrix or array... whatever it is....
	IsInCorrMissionDir = [logical(size(strfind(wholepathfilename,MISSION_ID),2) >= 2),false];
	IsInCorrMissionDir = IsInCorrMissionDir(1);

	
	
function [MPATH, MISSION_ID,RDRNUM,TYPE,MYRDRFILENAME] = GET_RDR_Info(wholepathfilename)
    
	wholepathfilename = regexprep(regexprep(regexprep(wholepathfilename,'rdr ','rdr'),'rdr ','rdr'),'rdr ','rdr');
	wholepathfilename = regexprep(regexprep(regexprep(wholepathfilename,'RDR ','RDR'),'RDR ','RDR'),'RDR ','RDR');
	wholepathfilename = regexprep(regexprep(regexprep(wholepathfilename,'Rdr ','RDR'),'RDR ','RDR'),'RDR ','RDR');
	if ispc
        MRT = utils.misc.strsplit(wholepathfilename,'\\');
        MRT = utils.misc.strsplit(char(regexprep(MRT(size(MRT,2)),'.asc','')),' ');
    else
        MRT = utils.misc.strsplit(wholepathfilename,'/');
        MRT = utils.misc.strsplit(char(regexprep(MRT(size(MRT,2)),'.asc','')),' ');
    end
	MISSION_ID = MRT(1);
	RDRNUM = str2double(regexprep(regexprep(MRT(2),'[A-Z]',''),'[a-z]',''));
	IMPCT = logical(sum(cell2mat(strfind(upper(MRT(3)),'IMPACT'))) > 0);
	PSHER = logical(sum(cell2mat(strfind(upper(MRT(3)),'PUSHER'))) > 0);
	DMRT3 = ~or(IMPCT,PSHER);
	while DMRT3
        MRT(3) = [];
        IMPCT = logical(sum(cell2mat(strfind(upper(MRT(3)),'IMPACT'))) > 0);
        PSHER = logical(sum(cell2mat(strfind(upper(MRT(3)),'PUSHER'))) > 0);
        DMRT3 = ~or(IMPCT,PSHER);
	end
    
	TYPE = upper(MRT(3));
	WPFN = wholepathfilename;
	midpos = strfind(char(WPFN),char(MISSION_ID)); % mission path mission id position
	MPATH = WPFN(1:midpos+size(char(MISSION_ID),2));
	
	MYRDRFILENAME = char(strcat('RDR','_',num2str(RDRNUM),'_',TYPE));
	
	
	
	
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


function [THISDIR,DWORKDIR,PATHTOMYFILE,PATHTOERRLOG,PATHTOSRCLOG] = buildtmppath(MYRDRFILENAME)
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
		DWORKDIR = horzcat(DWORKDIR,'\',MYRDRFILENAME);
		PATHTOMYFILE = horzcat(DWORKDIR,'\',MYRDRFILENAME);
		PATHTOERRLOG = horzcat(DWORKDIR,'\','Error.log');
		PATHTOSRCLOG = horzcat(DWORKDIR,'\','Source.log');
	else
		DWORKDIR = horzcat(DWORKDIR,'/',MYRDRFILENAME);
		PATHTOMYFILE = horzcat(DWORKDIR,'/',MYRDRFILENAME);
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