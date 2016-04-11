function [VALID,TABLES,INTPATH] = import_Table1(wholepathfilename)

    % Every file is innocent until proven guilty!
    VALID = 1;
	
	% Build internal paths structure
	INTPATH = build_INTPATHs();

	% Load './.tmp/TABLES.mat'.  This function also creates the .mat file
	% if it doesn't exist
	TABLES = load_TABLESmat(INTPATH.TABLES);

    if nargin == 0
	% No input detected
        [FileName,PathName,FilterIndex] = uigetfile('*.*');
    
        % File was selected, build the path to that file
        if logical(FileName(1) > 0) && logical(PathName(1) > 0) && logical(FilterIndex(1) > 0)
            wholepathfilename = horzcat(PathName,FileName);
		else
		% File was not selected, so set the path to the internal path
            wholepathfilename = INTPATH.TABLE1.TABLE1;
        end
    else
	% Skip the whole GUI getfile thing, an input was given!
	% This person knows what they want!
        wholepathfilename = utils.files.GetFullPath(wholepathfilename);
		if ~exist(wholepathfilename)
			VALID = 0;
			MISSION_ID = TABLES.MID;
			return
		end
    end


infileexists = logical(exist(wholepathfilename, 'file'));
NotmyFile = nMatch(wholepathfilename,INTPATH.TABLE1.TABLE1);
YESREPLACE = NotmyFile & infileexists;
if YESREPLACE
    copyfile(wholepathfilename, INTPATH.TABLE1.TABLE1,'f');
end
    

if logical(exist(INTPATH.TABLE1.TABLE1, 'file'))
    % keep .tmp hidden!
    if NotmyFile
        WPFN = wholepathfilename;
	else
		% gets only the primary source path from the .tmp/Source.log
		WPFN = utils.files.getSources(INTPATH.TABLE1.SRCLOG,true);
		wholepathfilename = WPFN;
	end
	
	
	if nMatch(WPFN,TABLES.MID)
	% The path to the input file does not match the mission path,
	% So obviously we want a new mission, and therefore a new dot mat file
		delete(INTPATH.TABLES);
		TABLES = load_TABLESmat(INTPATH.TABLES);
	end
	
	import java.io.*;
	T1f = dir(wholepathfilename);
	moddate = T1f.date();
	moddate = utils.misc.strsplit(regexprep(moddate,'-',' '));
	moddate = strtrim(moddate(3));

	%log the path to the selected Table 1 to Source.log
	utils.misc.logit(1,INTPATH.TABLE1.SRCLOG,WPFN,false,false);

	%clear fid tline FMTLin_Str FMTSLin_Str TABLE1_BWs;

	fid = fopen(INTPATH.TABLE1.TABLE1);

	WPFNForLog = WPFN;

	if size(WPFN,2) >= 60 && size(WPFN,2) < 120
		WPFNForLog = horzcat(WPFN(1:60),'\n\t',WPFN(61:size(WPFN,2)));
	elseif size(WPFN,2) >= 120
		WPFNForLog = horzcat(WPFN(1:60),'\n\t',WPFN(61:120),'\n\t',WPFN(121:size(WPFN,2)));
	end

utils.misc.logit(1,INTPATH.TABLE1.ERRLOG,horzcat('New Import\n\t',WPFNForLog),false,true);
tline = fgetl(fid);
which_line_am_I_on = 0;
LookAtOtherLineTypes = 0;


while ischar(tline)
	
    % Use this just to validate the file
    % it shouldn't pass the number 20 (just a random pick)
    % without filling in MISSION ID, First Motion Time and Place
    which_line_am_I_on = which_line_am_I_on + 1;
    
    if ~LookAtOtherLineTypes && which_line_am_I_on < 20
        
        if Match(tline, 'MISSION :')

            THISMID = regexprep(regexprep(regexprep(tline,'MISSION :',''),'\t',''),' ','');
			utils.misc.logit(2,INTPATH.TABLE1.ERRLOG,horzcat('MISSION ID\t',THISMID),false,true);
			MISSION_ID = THISMID;
			
			if exist(INTPATH.TABLES,'file')
				load(INTPATH.TABLES);
			else
				TABLES = struct('MPATH',MPATH,'MID',MISSION_ID);
			end			

			% Use THISMID and THISMID, if TABLES.MID is not THISMID then
			% itll create a new mission TABLES.mat file
			[MISSION_ID,TABLES] = Check_n_fix_MID(THISMID,THISMID,TABLES,INTPATH.TABLES);
        
        elseif Match(tline, 'FIRST MOTION REAL TIME:')
            FMTLin_Str = tline;
            FMTLin_Str = regexprep(FMTLin_Str,'FIRST MOTION REAL TIME:[%\s]', strcat(moddate,':'));
            FMTLin_Str = regexprep(FMTLin_Str,'\.',':');
            FMTLin_Str = regexprep(FMTLin_Str,' ','');
            
            FMTLin_Str = utils.nav.Tbl1JDTtoNorm(strtrim(FMTLin_Str));

            TABLE1_BWs{1} = 'First Motion';
            TABLE1_BWs{4} = '0';
            TABLE1_BWs{3} = FMTLin_Str;
			

        elseif Match(tline, 'LAUNCH POINT:')
            
            FMTSLin_Str = tline;
            FMTSLin_Str = regexprep(FMTSLin_Str,'LAUNCH POINT:[%\s]','');
            FMTSLin_Str =utils.misc.strsplit(strtrim(FMTSLin_Str));
			FMTSLin_Str = char(FMTSLin_Str(1));
			if str2double(char(FMTSLin_Str)) > 52800 || str2double(char(FMTSLin_Str)) < 0
				BADVAL = FMTSLin_Str;
				[VALID_FS,WPFN1,MISSIONID_FS,FMTS_FS] = utils.misc.GLPTSpRelT1(MISSION_ID,wholepathfilename);
				% Apply New Launch Point
				if VALID_FS
					FMTSLin_Str = char(FMTS_FS);
					utils.misc.logit(2,INTPATH.TABLE1.SRCLOG,WPFN1,false,false);
				
				%ENTRY = 'BAD: LaunchPoint out of bounds!!! '
					ENTRY = horzcat('BAD: Launch Point @ ',BADVAL,'\n');
					ENTRY = horzcat(ENTRY,'FIX: LaunchPoint sourced from:\n\n');
					WPFNForLog = WPFN1;
				
					if size(WPFN1,2) >= 60 && size(WPFN1,2) < 120
						WPFNForLog = horzcat(WPFN1(1:60),'\n\t',WPFN1(61:size(WPFN1,2)));
					elseif size(WPFN1,2) >= 120
						WPFNForLog = horzcat(WPFN1(1:60),'\n\t',WPFN1(61:120),'\n\t',WPFN1(121:size(WPFN1,2)));
					end

					ENTRY = horzcat(ENTRY,'\t',WPFNForLog);
					ENTRY = horzcat(ENTRY,'\n\n\tNew Launch Point @ ',FMTSLin_Str,'\n');
					utils.misc.logit(2,INTPATH.TABLE1.ERRLOG,ENTRY,false,true);
				else					
					FMTSLin_Str = BADVAL;
					%FMTSLin_Str = NaN;
					utils.misc.logit(2,INTPATH.TABLE1.SRCLOG,WPFN1,false,false)
				
				%ENTRY = 'BAD: LaunchPoint out of bounds!!! '
					ENTRY = horzcat('BAD: Launch Point @ ',BADVAL,'\n');
					ENTRY = horzcat(ENTRY,'FIX: LaunchPoint sourced from (FAIL):\n\n');
					WPFNForLog = WPFN1;
				
					if size(WPFN1,2) >= 60 && size(WPFN1,2) < 120
						WPFNForLog = horzcat(WPFN1(1:60),'\n\t',WPFN1(61:size(WPFN1,2)));
					elseif size(WPFN1,2) >= 120
						WPFNForLog = horzcat(WPFN1(1:60),'\n\t',WPFN1(61:120),'\n\t',WPFN1(121:size(WPFN1,2)));
					end

					ENTRY = horzcat(ENTRY,'\t',WPFNForLog);
					ENTRY = horzcat(ENTRY,'\n\n\tLaunch Point @ ',FMTSLin_Str,'\n');
					utils.misc.logit(2,INTPATH.TABLE1.ERRLOG,ENTRY,false,true);
					
				end
			end

			if nMatch(FMTSLin_Str,'.00')
				FMTSLin_Str = horzcat(FMTSLin_Str,'.00');
			end
            TABLE1_BWs{2} = char(FMTSLin_Str);
            
        end
        
        if exist('FMTSLin_Str','var') && ...
           exist('FMTLin_Str','var') && ...
           exist('MISSION_ID','var') && ...
           ~isempty(FMTSLin_Str) && ...
           ~isempty(FMTLin_Str) && ...
           ~isempty(MISSION_ID)
       
        	LookAtOtherLineTypes = 1;
            
        end
        
    elseif LookAtOtherLineTypes
        
        if Match(tline, 'BW')
       
            BWLin_Str = Func_Line_Fix(tline,moddate,1);
            TABLE1_BWs = [TABLE1_BWs;BWLin_Str];
			%if str(char(TABLE1_BWs(size(TABLE1_BWs,1),4)),'99999') >= 1
			
			% Good Last Track Station, just in case a bad launch point, or
			% any other bad trackstation wasn't able to be fixed.
			GOODLTS = ~logical(str2double(TABLE1_BWs(size(TABLE1_BWs,1)-1,2)) >= 999999);
			if str2double(TABLE1_BWs(size(TABLE1_BWs,1),4)) >= 99999 && ...
				GOODLTS
			% Fix Bad Velocity
			
				t1 = cell2table(TABLE1_BWs(size(TABLE1_BWs,1)-1,3));
				t1 = datenum(t1.Var1(1))*86400;
				t2 = cell2table(TABLE1_BWs(size(TABLE1_BWs,1),3));
				t2 = datenum(t2.Var1(1))*86400;
				dt = t2 - t1;
					
				% For building the Error log entry
				SL1TC=3-size(char(TABLE1_BWs(size(TABLE1_BWs,1)-1,1)),2)/4;
				SL = cell2table(TABLE1_BWs(size(TABLE1_BWs,1)-1:size(TABLE1_BWs,1),:));
				Sl1 = horzcat('\t',SL.Var1(1),'\t',SL.Var2(1),'\t',char(SL.Var3(1)),'\t',SL.Var4(1),'\n');
				SL2TC=3-size(char(TABLE1_BWs(size(TABLE1_BWs,1),1)),2)/4;
				Sl2 = horzcat('\t',SL.Var1(2),'\t',SL.Var2(2),'\t',char(SL.Var3(2)),'\t',SL.Var4(2),'\n');
					
					
				y1 = str2double(TABLE1_BWs(size(TABLE1_BWs,1)-1,2));
				y2 = str2double(TABLE1_BWs(size(TABLE1_BWs,1),2));
				dy = y2 - y1;
				NewVel = cellstr(num2str(round(dy/dt,2)));
				
				while SL1TC>2
					Sl1 = horzcat('\t',Sl1);
					SL1TC = SL1TC - 1;
				end
				while SL2TC>2
					Sl2 = horzcat('\t',Sl2);
					SL2TC = SL2TC - 1;
				end
				
				ENTRY = 'BAD: Velocity @ ';
				ENTRY = horzcat(ENTRY,char(TABLE1_BWs(size(TABLE1_BWs,1),1)),': ',char(TABLE1_BWs(size(TABLE1_BWs,1),4)),'\n');
				ENTRY = horzcat(ENTRY,'FIX: Recalculate from current Table Data\n\n');
				ENTRY = horzcat(ENTRY,Sl1,Sl2);
				TABLE1_BWs(size(TABLE1_BWs,1),4) = NewVel;
				ENTRY = horzcat(ENTRY,'\n\tNew Velocity @ ',char(TABLE1_BWs(size(TABLE1_BWs,1),1)),': ',char(NewVel),'\n');
				utils.misc.logit(2,INTPATH.TABLE1.ERRLOG,ENTRY,true,true);
			
			end
   
        elseif Match(tline, 'FB MON') || ...
               Match(tline, 'FB_MON') || ...
               Match(tline, 'FBMON')

            BWLin_Str = Func_Line_Fix(tline,moddate,2);
            TABLE1_FBs = BWLin_Str;
                        
        elseif Match(tline, 'STG')
        
            BWLin_Str = Func_Line_Fix(tline,moddate,3);
            TABLE1_FBs = [TABLE1_FBs;BWLin_Str];
                    
        elseif Match(tline, 'WPFN:')
            
            WPFN = regexprep(tline,'WPFN:\t','');
            
        end
        
 elseif ~LookAtOtherLineTypes && which_line_am_I_on > 20
       
	   ENTRY = 'BAD: Invalid Table 1\n\tEither MissionID, Launch Point, or First Motion Time variables\n\tnot filled before reading line 20';
	   utils.misc.logit(2,INTPATH.TABLE1.ERRLOG,ENTRY,false,true);

       VALID = 0;
       MISSION_ID = '';
       TABLE1_BWs=cell2table([{char('CMD'),1,datetime,0};{char('First Motion'),2,datetime+.0001,0};{char('BW1'),3,datetime()+.0002,1}]);
       TABLE1_BWs.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity'};
	   TABLE1_FBs = TABLE1_BWs;
       
            if NotmyFile
                WPFN = wholepathfilename;
            else
                WPFN = '';
            end
       return
    

    end
	
    tline = fgetl(fid);
end



	%TABLE1_BWs = circshift(TABLE1_BWs,1);
	TABLE1_BWs = cell2table(TABLE1_BWs);
	TABLE1_BWs.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity'};
	TABLE1_BWs.TS = str2double(TABLE1_BWs.TS);
	TABLE1_BWs.Velocity = str2double(TABLE1_BWs.Velocity);
	TABLE1_BWs.Function = regexprep(TABLE1_BWs.Function,'_','-');

	TABLE1_FBs = cell2table(TABLE1_FBs);
	TABLE1_FBs.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity'};
	TABLE1_FBs.TS = str2double(TABLE1_FBs.TS);
    TABLE1_FBs.Velocity = str2double(TABLE1_FBs.Velocity);
	
	for i=1:1:size(TABLE1_FBs.Velocity)
		%S = char(TABLE1_FBs.Velocity(i));
		%S1 = '99999.0';
		%BadVel = le(strfind(S,S1),1);
		BadVel = TABLE1_FBs.Velocity(i) >= 99999;

		SS = char(TABLE1_FBs.Function(i));
		SS1 = 'STG';
		isSTG = le(strfind(SS,SS1),1);
    
		if BadVel && isSTG && GOODLTS
			% interpolate the actual velocity
			WMATBWTS = table2cell(TABLE1_BWs);
			WMATFBTS = table2cell(TABLE1_FBs);
			WMATBWTS = WMATBWTS(:,2);
			WMATFBTS = WMATFBTS(:,2);
			DPOL=(TABLE1_BWs.TS(3)-TABLE1_BWs.TS(2))/(TABLE1_BWs.TS(3)-TABLE1_BWs.TS(2));
			ii = 0;
			BWTS = cell2mat(WMATFBTS(i));
			FBTS = cell2mat(WMATBWTS(ii+1));
			STC = (BWTS - FBTS)/abs(BWTS-FBTS);
			while STC == (BWTS - FBTS)/abs(BWTS-FBTS)
				ii = ii+1;
				BWTS = cell2mat(WMATFBTS(i));
				FBTS = cell2mat(WMATBWTS(ii));
			end
			
			ii = ii - 1;
			
			WMATFBTS = double(cell2mat(WMATFBTS(i)));
			
			% For building the Error log entry
			
			SL1TC = 3-size(char(TABLE1_BWs.Function(ii,:)),2)/4;
			SL = [TABLE1_BWs(ii,:);TABLE1_FBs(i,:)];
			
			Sl1 = horzcat('\t',SL.Function(1),'\t',num2str(SL.TS(1)),'\t',char(SL.Time(1)),'\t',num2str(SL.Velocity(1)),'\n');
			
			SL2TC = 3-size(char(TABLE1_FBs.Function(i,:)),2)/4;
			Sl2 = horzcat('\t',SL.Function(2),'\t',num2str(SL.TS(2)),'\t',char(SL.Time(2)),'\t',num2str(SL.Velocity(2)),'\n');
			
			while SL1TC>2
				Sl1 = horzcat('\t',Sl1);
				SL1TC = SL1TC - 1;
			end
			while SL2TC>2
				Sl2 = horzcat('\t',Sl2);
				SL2TC = SL2TC - 1;
			end
			
			ENTRY = 'BAD: Velocity @ ';
			ENTRY = horzcat(ENTRY,char(TABLE1_FBs.Function(i)),': ',num2str(TABLE1_FBs.Velocity(i)),'\n');
			ENTRY = horzcat(ENTRY,'FIX: Recalculate from current Table Data\n\n');
			ENTRY = horzcat(ENTRY,Sl1,Sl2);
			
			%TABLE1_FBs.Velocity = str2double(TABLE1_FBs.Velocity);

			TABLE1_FBs(i,:) = utils.math.fixVel(TABLE1_FBs(i,:),TABLE1_BWs);
			
			ENTRY = horzcat(ENTRY,'\n\tNew Velocity @ ',char(TABLE1_FBs.Function(i)),': ',num2str(TABLE1_FBs.Velocity(i)),'\n');
			utils.misc.logit(2,INTPATH.TABLE1.ERRLOG,ENTRY,true,true);
			
		end
	end

	TABLE1_FBs.Function = regexprep(TABLE1_FBs.Function,'_','-');
	



	if NotmyFile
		fid = fopen(INTPATH.TABLE1.TABLE1,'a');
		fprintf(fid,'\n');
		fprintf(fid,'WPFN:\t');
		fprintf(fid,'%s',WPFN);
		fclose(fid);
	end


	midpos = strfind(WPFN,MISSION_ID); % mission path mission id position
	MisPath = WPFN(1:midpos+size(MISSION_ID,2));
	TABLES.('MPATH') = MisPath;
	TABLES.('MID') = MISSION_ID;
	
	%Build a sub structure to go inside of the Main Tables struct, for all
	%of the Table 1 specific stuff
	TABLE1 = struct('BW',TABLE1_BWs,'FB',TABLE1_FBs);
	TABLE1.BW.DateTime = TABLE1.BW.Time;
	TABLE1.BW.Time = utils.nav.ZeroTinSec(TABLE1.BW.Time);
	TABLE1.FB.DateTime = TABLE1.FB.Time;
	TABLE1.FB.Time = utils.nav.ZeroTinSec(TABLE1.FB.Time);
	TABLES.('TABLE1') = TABLE1;
	
	save(INTPATH.TABLES,'TABLES');
	if exist(INTPATH.MISSION,'file')
		load(INTPATH.MISSION,'MISSION');
	%else
	%	MISSION = struct(MISSION_ID,TABLES)
	end
	Parent_MISSION = utils.misc.strsplit(MISSION_ID,'-');
	Parent_MISSION = char(cellstr(strcat('M_',Parent_MISSION(1))));
	Child_MISSION = utils.misc.strsplit(MISSION_ID,'-');
	Child_MISSION = char(Child_MISSION(2));
	MISSION.(Parent_MISSION).(Child_MISSION) = TABLES;
	save(INTPATH.MISSION,'MISSION');

else
    'I cant find any file here or there';
end


function TABLES = load_TABLESmat(TABLESPATH)
	if exist(TABLESPATH,'file')
	% Load './.tmp/TABLES.mat' if it exists
		load(TABLESPATH);
	else
	% './.tmp/TABLES.mat' doesn't exist, so create a new structure and save
	% it to './.tmp/TABLES.mat'
		TABLES = struct('MPATH','','MID','');
		save(TABLESPATH,'TABLES')
	end


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
		
		NEWSTRUCT = struct('FILE',FILE,'SRCLOG',SRCLOG,'ERRLOG',ERRLOG);
		%INTPATH.RDRX <- The String to go there
		RDR_entry = char(strcat(STR(1),STR(2)));
		%INTPATH.RDRX.IMPACT or INTPATH.RDRX.PUSHER
		PSHoIMP = char(STR(3));
		INTPATH.(RDR_entry).(PSHoIMP) = struct('FILE',FILE,'SRCLOG',SRCLOG,'ERRLOG',ERRLOG);
	end
	INTPATHPATH = horzcat(DWORKDIR,'INTPATH.mat');
	save(INTPATHPATH,'INTPATH');	



function nmatch=nMatch(string,mstring)
%
        nmatch = ~[logical(strfind(string,mstring)),logical(false)];
        nmatch = nmatch(1);
        
        
function match=Match(string,mstring)
%
        match = [logical(strfind(string,mstring)),logical(false)];
        match = match(1);

function Func_Line_Str = Func_Line_Fix(tline,moddate,kind)

    if kind == 1 % BW line
        while Match(tline,' BW') || Match(tline, 'BW_') || Match(tline, 'BW ')
            tline = regexprep(tline, ' BW', 'BW');
			tline = regexprep(tline, 'BW[_ ]', 'BW-');
            tline = regexprep(tline, 'BW[- ]', 'BW-');
        end
        
    elseif kind == 2 % FB Monitor Line
        while Match(tline, 'FB MON') || Match(tline, ' FB_MON')
            tline = regexprep(tline, 'FB[ _]MON', 'FB_MON');
            tline = regexprep(tline, ' FB[ _]MON', 'FB_MON');
        end
    elseif kind == 3 % STG Line
        tline = regexprep(tline, 'STG-', 'STG_');
        tline = regexprep(tline, 'STG ', 'STG_');
        while Match(tline,' STG') || Match(tline,' BU') || Match(tline,' _BU') || ...
              Match(tline,'__')
        
        	tline = regexprep(tline, ' BU', '_BU');              
            tline = regexprep(tline, ' STG', 'STG');
            tline = regexprep(tline, ' _BU', '_BU');
        end
    end
    if nMatch(tline, '\t')
    	tline = regexprep(tline, ' ','\t');
    end
    
    Func_Line_Str =utils.misc.strsplit(tline,'\t');
    
	Func_Line_Str(4) = [];
	Func_Line_Str(3) = strcat(moddate,':',Func_Line_Str(3));
	Func_Line_Str(3) = regexprep(Func_Line_Str(3),'\.',':');
	TimStr = char(Func_Line_Str(3));
	Func_Line_Str(3) = {utils.nav.Tbl1JDTtoNorm(TimStr)};
    
    %Func_Line_Str(3) = {Tbl1JDTtoNorm(char(Func_Line_Str(3)))};
    
    
function ARRAY =strsplit1(STRING,DELIM)
% This one seems faster than the original
    if ~exist('DELIM','var')
        DELIM = ' ';
    end
    TDELIM = horzcat(DELIM,DELIM,DELIM);
    DDELIM = horzcat(DELIM,DELIM);
    
    STRING = regexprep(STRING,TDELIM,DELIM);
    STRING = regexprep(STRING,DDELIM,DELIM);
    STRING = regexprep(STRING,TDELIM,DELIM);
    STRING = regexprep(STRING,DDELIM,DELIM);
    STRING = regexprep(STRING,TDELIM,DELIM);
    STRING = regexprep(STRING,DDELIM,DELIM);
    

    ARRAY = transpose(cellstr(strread(STRING,'%s','delimiter',DELIM)));
	
	
	
function [MISSION_ID,TABLES] = Check_n_fix_MID(THISMID,MISSION_ID,TABLES,T1P)
	if Match(THISMID,MISSION_ID) && Match(THISMID,TABLES.MID)
	%'Yay, The Mission ID matches the Mission ID!!!!'
		save(T1P,'TABLES');
	else
	%'Ooh, This Mission ID isnt correct....'
		delete(T1P);
		TABLES = struct('MID',THISMID);
	end
	
	
    