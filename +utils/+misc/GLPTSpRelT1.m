function [VALID,WPFN,MISSIONID,FMTS] = GLPTSpRelT1(MISSIONID,wholepathfilename)

	
    THISFILE = mfilename;
    THISDIR = mfilename('fullpath');
    THISDIR = THISDIR(1:end-size(THISFILE,2));
    DWORKDIR = horzcat(THISDIR,'.tmp');
    
	
	
	%if exist('wholepathfilename','var')
	if ispc
		
		DWORKDIR = regexprep(DWORKDIR,'+utils\','');
		slind = strfind(wholepathfilename,'\');
		slind = slind(size(slind,2)-1);	%Gitrid of the slash too
		MISSIONDIR = wholepathfilename(1:slind);
		
		slind = strfind(MISSIONDIR,'\');
		slind = slind(size(slind,2)-1);
		MISSIONTPDDIR = dir(horzcat(MISSIONDIR,'\TP *'));
		MISSIONTPDDIR = MISSIONTPDDIR.name;
		MISSIONTPDDIR = horzcat(MISSIONDIR,MISSIONTPDDIR);
		
		MFLDSHT = dir(horzcat(MISSIONTPDDIR,'\',MISSIONID,'*','F40OU*'));
		MFLDSHT = MFLDSHT.name;
		MFLDSHT = horzcat(MISSIONTPDDIR,'\',MFLDSHT);
		

		wholepathfilename = MFLDSHT;
		WPFN = wholepathfilename;
	else
		
		DWORKDIR = regexprep(DWORKDIR,'+utils/','');
		slind = strfind(wholepathfilename,'/');
		slind = slind(size(slind,2)-1);	%Gitrid of the slash too
		MISSIONDIR = wholepathfilename(1:slind);
		
		slind = strfind(MISSIONDIR,'/');
		slind = slind(size(slind,2)-1);
		MISSIONTPDDIR = dir(horzcat(MISSIONDIR,'/TP *'));
		MISSIONTPDDIR = MISSIONTPDDIR.name;
		MISSIONTPDDIR = horzcat(MISSIONDIR,MISSIONTPDDIR);
		
		MFLDSHT = dir(horzcat(MISSIONTPDDIR,'/',MISSIONID,'*','F40OU*'));
		MFLDSHT = MFLDSHT.name;
		MFLDSHT = horzcat(MISSIONTPDDIR,'/',MFLDSHT);
		

		wholepathfilename = MFLDSHT;
		WPFN = wholepathfilename;
	end
	
    % If the Data Work Directory doesn't exist
    %   create it

    if ~(exist(DWORKDIR, 'dir'));
        mkdir(DWORKDIR);
		if ispc
			fileattrib(DWORKDIR,'+h');
		end
	else exist(DWORKDIR, 'dir') > 0;

		if ispc
			fileattrib(DWORKDIR,'+h');
		else
		end
	end

    % finish building path to My copy of Table 1, for copying
    % and/or importing
    if ispc
        PATHTOMYTABLE1 = horzcat(DWORKDIR,'\','FieldSheets');
    elseif isunix
        PATHTOMYTABLE1 = horzcat(DWORKDIR,'/','FieldSheets');
    end
        
    % No input detected
    if nargin == 0
        [FileName,PathName,FilterIndex] = uigetfile('*.*');
    
        % File was selected
        if logical(FileName(1) > 0) && logical(PathName(1) > 0) && logical(FilterIndex(1) > 0)
            wholepathfilename = horzcat(PathName,FileName);
    
        % File was not selected
        else
            %wholepathfilename = logical(0)
            % Just set the path to whatever's in .tmp
            wholepathfilename = PATHTOMYTABLE1;
        end
    
    % Input was given    
    else
        wholepathfilename = utils.files.GetFullPath(wholepathfilename);
    end

infileexists = logical(exist(wholepathfilename, 'file'));

% Make sure my file isnt the input
NotmyFile = nMatch(wholepathfilename,PATHTOMYTABLE1);

% it's not my file and the input file does exist
% so we can replace my file in my directory
% with the input file
YESDELETE = NotmyFile & infileexists;

if YESDELETE
    copyfile(wholepathfilename, PATHTOMYTABLE1,'f');
end
    

if exist(PATHTOMYTABLE1, 'file')
    % keep .tmp hidden!
    if NotmyFile
        WPFN = wholepathfilename;
    else
        WPFN = '';
    end

clear fid tline FMTLin_Str FMTSLin_Str TABLE1_BWs
fid = fopen(PATHTOMYTABLE1);
tline = fgetl(fid);
which_line_am_I_on = 0;
LookAtOtherLineTypes = 0;

while ischar(tline)
    %Use this to just to validate the file
    % it shouldn't pass the number 20 (just a random pick)
    % without filling in MISSION ID, First Motion Time and Place

    which_line_am_I_on = which_line_am_I_on + 1;
    if ~LookAtOtherLineTypes && which_line_am_I_on < 500
        
		if Match(tline,'MISSION:')
			if Match(tline, MISSIONID)
				MISSION_ID = MISSIONID;
			else
				VALID = 0;
				WPFN = wholepathfilename;
				FMTS = NaN;
				return
			end
        elseif Match(tline, 'LAUNCH POINT:')
            
            
			while strfind(tline,'LAUNCH POINT:') > 1
				tline = tline(2:size(tline,2));
			end
			FMTSLin_Str = tline;
            FMTSLin_Str = regexprep(FMTSLin_Str,'LAUNCH POINT:[%\s]','');
            FMTSLin_Str = strsplit(strtrim(FMTSLin_Str));
			FMTSLin_Str = FMTSLin_Str(1);
            
        end
        
        if exist('FMTSLin_Str','var') && ...
           exist('MISSION_ID','var') && ...
           ~isempty(FMTSLin_Str) && ...
           ~isempty(MISSION_ID)
       
			
			FMTS = str2double(FMTSLin_Str);
			if FMTS > 0 & FMTS <= 52800 & strfind(MISSION_ID,MISSIONID) == 1
				VALID= 1;
			end
			FMTS = FMTSLin_Str;
			MISSIONID = MISSION_ID;
			
        	LookAtOtherLineTypes = 0;
			return
            
        end
        
    elseif LookAtOtherLineTypes
        
        if Match(tline, 'WPFN:')
            
            WPFN = regexprep(tline,'WPFN:\t','');
            
        end
        
 elseif ~LookAtOtherLineTypes && which_line_am_I_on > 20
       
       fprintf('Invalid File\n');
       VALID = 0;
       MISSION_ID = '';
       
            if NotmyFile
                WPFN = wholepathfilename;
            else
                WPFN = '';
			end
            

       delete(PATHTOMYTABLE1);
       return;
    

    end
	
    tline = fgetl(fid);
end

if exist('TABLE1_FBs','var')
    TABLE1_FBs;
end

%TABLE1 = circshift(TABLE1,1);
%TABLE1 = cell2table(TABLE1);
%TABLE1.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity'};
%TABLE1.Velocity = str2double(TABLE1.Velocity);
%TABLE1.TS = str2double(TABLE1.TS);

if NotmyFile
    fid = fopen(PATHTOMYTABLE1,'a');
    fprintf(fid,'\n');
    fprintf(fid,'WPFN:\t');
    fprintf(fid,'%s',WPFN);
    fclose(fid);
end


else
    'I cant find any file here or there';
end


function nmatch=nMatch(string,mstring)
%
        nmatch = ~[logical(strfind(string,mstring)),logical(0)];
        nmatch = nmatch(1);
        
        
function match=Match(string,mstring)
%
        match = [logical(strfind(string,mstring)),logical(0)];
        match = match(1);

function Func_Line_Str = Func_Line_Fix(tline,moddate,kind)
%
    if kind == 1 % BW line
        while Match(tline,' BW') || Match(tline, 'BW-') || Match(tline, 'BW ')
            tline = regexprep(tline, ' BW', 'BW');
            tline = regexprep(tline, 'BW[- ]', 'BW_');
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
    
        
	Func_Line_Str = strsplit(tline,'\t');
	%if (size(Func_Line_Str,2) <= 4)
	%	Func_Line_Str = strsplit(tline,' ')
	%end
		
        
	Func_Line_Str(4) = [];
	Func_Line_Str(3) = strcat(moddate,':',Func_Line_Str(3));
	Func_Line_Str(3) = regexprep(Func_Line_Str(3),'\.',':');
	TimStr = char(Func_Line_Str(3));
	Func_Line_Str(3) = {Tbl1JDTtoNorm(TimStr)};
    %Func_Line_Str(3) = {Tbl1JDTtoNorm(char(Func_Line_Str(3)))};
    