function varargout = Table1Visualizer(varargin)
% TABLE1VISUALIZER MATLAB code for Table1Visualizer.fig
%      TABLE1VISUALIZER, by itself, creates a new TABLE1VISUALIZER or raises the existing
%      singleton*.
%
%      H = TABLE1VISUALIZER returns the handle to a new TABLE1VISUALIZER or the handle to
%      the existing singleton*.
%
%      TABLE1VISUALIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLE1VISUALIZER.M with the given input arguments.
%
%      TABLE1VISUALIZER('Property','Value',...) creates a new TABLE1VISUALIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Table1Visualizer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Table1Visualizer_OpeningFcn via varargin.
%
%      *See GUI View on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Table1Visualizer

% Last Modified by GUIDE v2.5 17-Apr-2016 12:19:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Table1Visualizer_OpeningFcn, ...
                   'gui_OutputFcn',  @Table1Visualizer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



function Table1Visualizer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Table1Visualizer (see VARARGIN)

% Load Previous states

% Choose default command line output for Table1Visualizer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using Table1Visualizer.
%%MARKER


%fig = figure
%fig.DockControls = 'off'


    
    
	
	PATHTOLOCALTABLE1 = get_tmpFilePath('Table 1');
	if ismember(handles.dnt_fix_stage_vels.Checked,'on')
		VELFIXSTR = 'Dont Fix STG Vels';
	elseif ismember(handles.fix_all_stage_vels.Checked,'on')
		VELFIXSTR = 'Fix All STG Vels';
	elseif ismember(handles.fix_bad_stage_vels.Checked,'on')
		VELFIXSTR = 'Fix Bad STG Vels';
	else
		VELFIXSTR = 'Fix Bad STG Vels';
	end
	
    if exist(PATHTOLOCALTABLE1,'file')
        [VALID,TABLES,INTPATH] =  import_Table1(PATHTOLOCALTABLE1,VELFIXSTR);
    else
        [VALID,TABLES,INTPATH] =  import_Table1;
    end
    fclose('all');
    
    if exist(INTPATH.TABLE1.TABLE1,'file') & ~VALID
        [VALID,TABLES,INTPATH] =  import_Table1;
    end
    
    handles = guidata(hObject);
	handles.INTPATH = INTPATH;
	handles.TABLES = TABLES;
	handles.VALID = VALID;
	

	if logical(sum(ismember(fieldnames(handles),'TblsMChkdItems')))
		TblsMChkdItems = handles.TblsMChkdItems;
	else
		TblsMChkdItems = '';
		handles.TblsMChkdItems = TblsMChkdItems;
	end
	updateSources(handles);
	updateTables(handles,INTPATH);
	try
		[FUNCTIONS,STYLES,LEGEND,TBL,TinT] = CombineSelectedTables(handles.TblsMChkdItems,TABLES);
	catch e
		[FUNCTIONS,STYLES,LEGEND,TBL,TinT] = CombineSelectedTables('',TABLES);
	end
	MISSION_ID = TABLES.MID;

	handles.FUNCTIONS = FUNCTIONS;
	handles.STYLES = STYLES;
	handles.LEGEND = LEGEND;
	handles.TinT = TinT;
	handles.TBL = TBL;
	guidata(hObject, handles);
	
    if ~VALID
        MISSION_ID = 'Invalid File';
        handles.figure1.Name = MISSION_ID;
        set(handles.MID_field,'String',MISSION_ID);
    else
        handles.figure1.Name = MISSION_ID;
        set(handles.MID_field,'String',horzcat(['Mission ID:','  ',MISSION_ID]));
	end
		WPFN = getTable1Path(handles);
        set(handles.popupmenu1,'Value',2);
        set(handles.popupmenu2,'Value',4);
		updateSources(handles);
		updateTables(handles,INTPATH);
		VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
		ViewSwitch(TBL,false,handles,VIEW);
		
		

% UIWAIT makes Table1Visualizer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Table1Visualizer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1);

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1);


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

	handles = guidata(gcbo);
	
    TABLES = handles.TABLES;
	%TblsMChkdItems = handles.TblsMChkdItems;
	[FUNCTIONS,STYLES,LEGEND,TBL,TinT] = CombineSelectedTables(handles.TblsMChkdItems,TABLES);

	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TBL,true,handles,VIEW);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
%end

%set(hObject, 'String', {'plot(rand(5))', 'plot(sin(1:0.01:25))', 'bar(1:.5:10)', 'plot(membrane)', 'surf(peaks)'});


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

	TABLES = handles.TABLES;
	handles = guidata(gcbo);
	TblsMChkdItems = handles.TblsMChkdItems;
	[FUNCTIONS,STYLES,LEGEND,TBL,TinT] = CombineSelectedTables(TblsMChkdItems,TABLES);

	% Testing to feasability of quicklook view switch
	%updateGraphs(TBL,true,handles);
	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TBL,true,handles,VIEW);


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ViewSwitch(TABLE,MAINONLY,handles,VIEW)
% VIEW == 1, then Big 'n little 3
% VIEW == 2, then Quick View

	if VIEW == 1
		handles.popupmenu1.Visible = 'on';
		handles.popupmenu2.Visible = 'on';
		handles.MID_field.Visible = 'on';
		
		%may not exist for much longer
		handles.MXVplttxt.Visible = 'off';
		handles.IMPVplttxt.Visible = 'off';
		handles.MXVpltpnl.Visible = 'off';
		handles.IMPVpltpnl.Visible = 'off';
		%%%%
		
		updateGraphs_v1(TABLE,MAINONLY,handles);

	elseif VIEW == 2
		handles.popupmenu1.Visible = 'off';
		handles.popupmenu2.Visible = 'off';
		handles.MID_field.Visible = 'off';
		
		updateGraphs_v2(TABLE,handles);
		
		%disabled for testing
		handles.MXVplttxt.Visible = 'off';
		handles.IMPVplttxt.Visible = 'off';
		handles.MXVpltpnl.Visible = 'off';
		handles.IMPVpltpnl.Visible = 'off';
		
	else
		handles.popupmenu1.Visible = 'on';
		handles.popupmenu2.Visible = 'on';
		handles.MID_field.Visible = 'on';
		updateGraphs_v1(TABLE,MAINONLY,handles);
		
		%may not exist for much longer
		handles.MXVplttxt.Visible = 'off';
		handles.IMPVplttxt.Visible = 'off';
		handles.MXVpltpnl.Visible = 'off';
		handles.IMPVpltpnl.Visible = 'off';
		%%%%
		
	end


function updateGraphs_v2(TABLE,handles)

	TinT = handles.TinT;
	STYLES = handles.STYLES;
	LEGEND = handles.LEGEND;
	ACCSRCS = 'IMPACT';
	% FLINS (Func Line Styles) is a way better kick-ass variable
	FLINS = TBLFunctions_to_LineStyles_v2(TABLE,TinT);
	
	%subplot(100,2,1:2:150);

	if sum([strfind(handles.SaImpZoom.Checked,'off');0]) && ...
	   sum([strfind(handles.SaNoZoom.Checked,'off');0]);
		subplot(1,2,1);
		% Whole Plot Velocity vs Time
		WplotVT(TABLE,handles,TinT,STYLES,LEGEND,FLINS,ACCSRCS)
		%subplot(100,2,2:2:151);
		subplot(1,2,2);
		% Zoom Impact Plot Velocity vs Time
		ZIplotVT(TABLE,handles,TinT,STYLES,LEGEND,FLINS,ACCSRCS)
	elseif sum([strfind(handles.SaImpZoom.Checked,'on');0])
		subplot(1,1,1);
		ZIplotVT(TABLE,handles,TinT,STYLES,LEGEND,FLINS,ACCSRCS)
	elseif  sum([strfind(handles.SaNoZoom.Checked,'on');0])
		subplot(1,1,1);
		WplotVT(TABLE,handles,TinT,STYLES,LEGEND,FLINS,ACCSRCS)
	end
	


function WplotVT(TABLE,handles,TinT,STYLES,LEGEND,FLINS,ACCSRCS)

	plot(TABLE.Time,TABLE.Velocity), xlabel('UTC Time (s)'), ylabel('Velocity (ft/s)');;
	
	h = findobj(gca,'Type','line');
	try
		[h,handles] = ApplyLineStyles_v2(TABLE,FLINS,h,handles);

		Xmm = xlim();
		Ymm = ylim();
		
	catch e
		'';
	end

function ZIplotVT(TABLE,handles,TinT,STYLES,LEGEND,FLINS,ACCSRCS)


	MxImp = What_MxImp_Vels(TABLE,ACCSRCS);
	
	%Heres some stuff to kind of grade who has the best impact velocity in
	%comparison to breakwires, for zooming in.
	MxImpBW = What_MxImp_Vels(TABLE,'Breakwires');
	dIMPVel_fbw = MxImpBW.Velocity(2) - MxImp.Velocity(2,:);
	C_IMPVel_ind = find(ismember(dIMPVel_fbw,min(dIMPVel_fbw)));
	MxImp.Velocity(2,C_IMPVel_ind);
	
	% Percent of Full Scale future/past sides
	PoFShs = 7/100;
	%PoFShs = 5/100;
	PoFShsy = 8/100;
	PoFSls = 4/100;
	%PoFSls = 8/100;
	PoFSlsx = 3/100;
	
	% Full Scale V,T & DT Max to Impact
	FSV = abs(MxImp.Velocity(2,C_IMPVel_ind) - MxImp.Velocity(1,C_IMPVel_ind));
	FST = abs(MxImp.Time(2,C_IMPVel_ind) - MxImp.Time(1,C_IMPVel_ind));
	FSDT = abs(MxImp.DateTime(2,C_IMPVel_ind) - MxImp.DateTime(1,C_IMPVel_ind));
    
	% Zoom Window Extrema
	Ymx = MxImp.Velocity(2,C_IMPVel_ind)+(PoFShs*FSV);
	Ymn = MxImp.Velocity(2,C_IMPVel_ind)-(PoFSls*FSV);
	Xmn = MxImp.Time(2,C_IMPVel_ind)-(PoFShs*FST);
	Xmx = MxImp.Time(2,C_IMPVel_ind)+(PoFSls*FST);
	XmnDT = datenum(MxImp.DateTime(2,C_IMPVel_ind))-(PoFShs*FSDT);
	XmxDT = datenum(MxImp.DateTime(2,C_IMPVel_ind))+(PoFSls*FSDT);

	if ~exist('IMPAXIS','var')
		IMPAXIS = zeros(1,4);
	end
	IMPAXIS(3) = Ymn(1);
	IMPAXIS(4) = Ymx(1);
	IMPAXIS(1) = datenum(Xmn(1));
	IMPAXIS(2) = datenum(Xmx(1));

	plot(TABLE.Time,TABLE.Velocity), xlabel('UTC Time (s)'), ylabel('Velocity (ft/s)');
	
	try
		axis(IMPAXIS);
	catch e
		'';
	end
	
	h = findobj(gca,'Type','line');
	[h,handles] = ApplyLineStyles_v2(TABLE,FLINS,h,handles);
	
	
	
function updateGraphs_v1(TABLE1_BWs,boolMainonlyT,handles)
    
	TinT = handles.TinT;
	STYLES = handles.STYLES;
	LEGEND = handles.LEGEND;


	
    
    if ~logical(boolMainonlyT)
        axlbls =  cell(3,2);

        
        if Match(handles.Position_absolute.Checked, 'on')
            POSTYPE = 'P';
        else
            POSTYPE = 'p';
        end
        
        if Match(handles.Time_absolute.Checked, 'on')
            TIMTYPE = 'T';
        else
            TIMTYPE = 't';
        end

        % Small Position plot
        subplot(5,3,3);
        ylblp = cell(3,3);
        axlbls(1,:) = utils.math.plotTABLE1(TABLE1_BWs,TIMTYPE,POSTYPE);
        
		h = findobj(gca,'Type','line');
		'Small Plot 1';
		h = ApplyLineStyles_v1(TABLE1_BWs,TinT,STYLES,h);
		
        % Small Velocity Plot
        subplot(5,3,6);
        axlbls(2,:) = utils.math.plotTABLE1(TABLE1_BWs,TIMTYPE,'v');        
        
		h = findobj(gca,'Type','line');
		'Small Plot 2';
		h = ApplyLineStyles_v1(TABLE1_BWs,TinT,STYLES,h);
		
        % Small BW Plot
        subplot(5,3,9);
        axlbls(3,:) = utils.math.plotTABLE1(TABLE1_BWs,TIMTYPE,'BW');        

		h = findobj(gca,'Type','line');
		'Small Plot 3';
		h = ApplyLineStyles_v1(TABLE1_BWs,TinT,STYLES,h);
        
		Yselectorlbls = axlbls(:,2);
        Xselectorlbls = axlbls(:,1);
        Yselectorlbls = [Yselectorlbls;Xselectorlbls];
        Yselectorlbls = unique(Yselectorlbls);
    
        Xselectorlbls = transpose(Yselectorlbls);
        %subplot(3,1,3);
    
        %Logic for what the Big Main Graph displays
        %%%%%Figuring syntax for setting
        set(handles.popupmenu1, 'String', Xselectorlbls);
        set(handles.popupmenu2, 'String', Yselectorlbls);
        %%%%%%
        % Big Main Graph
	end
	subplot(21,12,1:6:144);
    %What is the string that has been selected to graph
    yaxisstr = get(handles.popupmenu2,'String');
    yaxisstr_index = get(handles.popupmenu2, 'Value');
    yaxisstr = char(yaxisstr(yaxisstr_index));
    
    xaxisstr = get(handles.popupmenu1,'String');
    xaxisstr_index = get(handles.popupmenu1, 'Value');
    xaxisstr = char(xaxisstr(xaxisstr_index));
    
    

    xstr = axisstr_to_cmdstr(xaxisstr);
    ystr = axisstr_to_cmdstr(yaxisstr);
    
    utils.math.plotTABLE1(TABLE1_BWs,xstr,ystr);
    

	h = findobj(gca,'Type','line');
	h = ApplyLineStyles_v1(TABLE1_BWs,TinT,STYLES,h);

	% Turn on the Legend... that's me :)
	h = legend('show');
	h.String = LEGEND;
	%h.Location = 'northwestoutside';
	lp = get(h,'position');
	
	%Top Left outside Big plot
	%set(h,'position',[.025,.8,lp(3:4)])
	%Bottom Right, like any other legend should be.
    set(h,'position',[0.7825,0.1,lp(3:4)]);
	
	%set(handles.figure1,'toolbar','figure');
	
	
	

function cmdstr = axisstr_to_cmdstr(axislabel)
    if strfind(axislabel,'Position (relative)') >= 1
        cmdstr = 'p';
    elseif strfind(axislabel,'elative') >= 1 & strfind(axislabel,'ositio') >= 1
        cmdstr = 'p';    
    elseif strfind(axislabel,'Position (absolute)') >= 1
        cmdstr = 'P';
    elseif strfind(axislabel,'solute') >= 1 & strfind(axislabel,'ositio') >= 1
        cmdstr = 'P';
    elseif strfind(axislabel,'Velocity') >= 1
        cmdstr = 'v';
    elseif strfind(axislabel,'BW') >= 1
        cmdstr = 'BW';
    elseif strfind(axislabel,'ime') >= 1 & strfind(axislabel,'elative') >= 1
        cmdstr = 't';
    elseif strfind(axislabel,'ime') >= 1 & strfind(axislabel,'bsolute') >= 1
        cmdstr = 'T';
    end


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Open_RDR_Callback(hObject, eventdata, handles)
% hObject    handle to Open_RDR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	
	INTPATH = utils.files.build_INTPATHs(mfilename,mfilename('fullpath'));
	load(char(INTPATH.TABLES),'TABLES');
	STARTPATH = strcat(TABLES.MPATH,'*.asc');
	
	[FileName,PathName,FilterIndex] = uigetfile(STARTPATH,'import RADAR.asc file','MultiSelect','on');
	
	if isstr(FileName) || iscellstr(FileName)
		FILEQUANT = size(cellstr(FileName),2);
	else
		FILEQUANT = 0;
	end
	
	for i=1:FILEQUANT
		if FILEQUANT > 1
			wholepathfilename = char(strcat(PathName,FileName(i)));
		else
			wholepathfilename = char(strcat(PathName,FileName));
		end
		
		[VALID,TABLES,INTPATH,RFK] = import_TableRADAR(wholepathfilename);
		fclose('all');
		try
			RFK = regexprep(regexprep(RFK,'MPACT','mpact'),'USHER','usher');
			Reload_Callback(hObject, eventdata, handles);
			TBLMIs = findall(handles.Tables_menu);

			TMEs1 = handles.Tables_menu.Children;
			TMEsL1 = {TMEs1.Label};
			if size(TMEs1,1) > 0
				TMEsL1 = transpose(TMEsL1);
			end
			RMPOS1 = sum(find(ismember(TMEsL1,RFK(1))));
	
			TMEs2 = TMEs1(RMPOS1).Children;
			TMEsL2 = {TMEs2.Label};
			if size(TMEs1,1) > 0
				TMEsL2 = transpose(TMEsL2);
			end
			RMPOS2 = sum(find(ismember(TMEsL2,RFK(2))));
	
			TMEs3 = TMEs2(RMPOS2).Children;
			TMEsL3 = {TMEs3.Label};
			if size(TMEs2,1) > 0
				TMEsL3 = transpose(TMEsL3);
			end
			RMPOS3 = sum(find(ismember(TMEsL3,RFK(3))));
			% Turn it off before sending the object to the callback, because it's
			% going to toggle it.
			TMEs3(RMPOS3).Checked = 'off';
			Tables_menu_children_Callback(TMEs3(RMPOS3),eventdata,handles,TABLES);
	
			%updateSources(handles);
			%updateTables(handles,INTPATH);
			%Reload_Callback(hObject, eventdata, handles);
		catch e
			'';
		end
	end
	
% --------------------------------------------------------------------
function Open_Callback(hObject, eventdata, handles)
% hObject    handle to Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
	%global TABLE1_BWs TABLE1_FBs MISSION_ID VALID
	INTPATH = utils.files.build_INTPATHs(mfilename,mfilename('fullpath'));
	load(char(INTPATH.TABLES),'TABLES');
	STARTPATH = strcat(TABLES.MPATH,'*.txt');
	
	[FileName,PathName,FilterIndex] = uigetfile(STARTPATH,'import Table 1');
	if isstr(FileName)
		wholepathfilename = char(strcat(PathName,FileName));
		[VALID,TABLES,INTPATH] = import_Table1(wholepathfilename);
		fclose('all');
	end
	if ~exist('VALID','var')
		VALID = 1;
	end
    
    %Just in case we accidently select the wrong file
    if exist(INTPATH.TABLE1.TABLE1,'file') & ~VALID
        [VALID,TABLES,INTPATH] =  import_Table1;
    end
    
	MISSION_ID = TABLES.MID;
	TABLE1_BWs = TABLES.TABLE1.BW;
	TABLE1_FBs = TABLES.TABLE1.FB;
	%TABLE1_BWs = TABLES.RADAR{1}.IMPACT
    
	%TABLE1 = sortrows([TABLE1_BWs;TABLE1_FBs],2)
    
    if ~VALID
        MISSION_ID = 'Invalid File';
        handles.figure1.Name = MISSION_ID;
        set(handles.MID_field,'String',MISSION_ID);
    else
        handles.figure1.Name = MISSION_ID;
        set(handles.MID_field,'String',horzcat(['Mission ID:','  ',MISSION_ID]));
	end
	
	updateSources(handles);
	updateTables(handles,INTPATH);
	
	Reload_Callback(hObject, eventdata, handles);
	
	
    %updateGraphs(TABLE1_BWs,false,handles);
	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TABLE1_BWs,false,handles,VIEW);


% --------------------------------------------------------------------
function View_Callback(hObject, eventdata, handles)
% hObject    handle to View (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Time_absolute_Callback(hObject, eventdata, handles)
% hObject    handle to Time_absolute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	%global TABLE1_BWs
	handles = guidata(gcbo);
	TBL = handles.TBL;
	handles.Time_absolute.Checked = 'on';
	handles.Time_relative.Checked = 'off';
	
	% Testing to feasability of quicklook view switch
	%updateGraphs(TBL,false,handles);
	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TBL,false,handles,VIEW);
	


% --------------------------------------------------------------------
function Time_relative_Callback(hObject, eventdata, handles)
% hObject    handle to Time_relative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	handles = guidata(hObject);
	TBL = handles.TBL;

	handles.Time_absolute.Checked = 'off';
	handles.Time_relative.Checked = 'on';

	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TBL,false,handles,VIEW);
	

% --------------------------------------------------------------------
function Position_absolute_Callback(hObject, eventdata, handles)
% hObject    handle to Position_absolute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	TBL = handles.TBL;
	handles.Position_absolute.Checked = 'on';
	handles.Position_relative.Checked = 'off';
	
	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TBL,false,handles,VIEW);


% --------------------------------------------------------------------
function Position_relative_Callback(hObject, eventdata, handles)
% hObject    handle to Position_relative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	TBL = handles.TBL;
	
	handles.Position_absolute.Checked = 'off';
	handles.Position_relative.Checked = 'on';
	
	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TBL,false,handles,VIEW);

% --------------------------------------------------------------------
function quickview_menuitem_Callback(hObject, eventdata, handles)
% hObject    handle to quickview_menuitem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	if ismember(handles.quickview_menuitem.Checked,'off')
		handles.quickview_menuitem.Checked = 'on';
	else
		handles.quickview_menuitem.Checked = 'off';
	end
	
	Reload_Callback(hObject, eventdata, handles);


function nmatch=nMatch(string,mstring)
%
	nmatch = ~[logical(strfind(string,mstring)),logical(0)];
	nmatch = nmatch(1);
        
        
function match=Match(string,mstring)
%
        
	match = [logical(strfind(string,mstring)),logical(0)];
	match = match(1);

		
function WPFN = getTable1Path(handles)

	SRCS = findall(handles.SOURCES);

	if size(SRCS,1) > 1
		
		for i=2:1:size(SRCS,1)
			if	Match(SRCS(i).Label,'Table1') ||...
				Match(SRCS(i).Label,'table1') ||...
				Match(SRCS(i).Label,'TABLE1') ||...
				Match(SRCS(i).Label,'Table 1') ||...
				Match(SRCS(i).Label,'table 1') ||...
				Match(SRCS(i).Label,'TABLE 1') ||...
				Match(SRCS(i).Label,'Table_1') ||...
				Match(SRCS(i).Label,'table_1') ||...
				Match(SRCS(i).Label,'TABLE_1')
			
				WPFN = SRCS(i).Label;
				i = size(SRCS,1)+1;
			end
		end
	else
		WPFN = '';
	end
	
	
function tmpFilePath = get_tmpFilePath(FILE_Name)

	THISFILE = mfilename;
	THISDIR = mfilename('fullpath');
	THISDIR = THISDIR(1:end-size(THISFILE,2));
	DWORKDIR = horzcat(THISDIR,'.tmp');
	if ispc
		tmpFilePath = horzcat(DWORKDIR,'\',FILE_Name);
    elseif isunix
		tmpFilePath = horzcat(DWORKDIR,'/',FILE_Name);
	end
	
function updateTables(handles,INTPATH)
	%global INTPATH
	load(INTPATH.TABLES,'TABLES');
	TBLMIs = findall(handles.Tables_menu);
	PSMs = handles.Tables_menu.Children;
	
	if size(PSMs,1) > 0
		PSMs = transpose({PSMs.Label});
		
		if sum(find(ismember(PSMs,'RADAR')))
			
			RADARmenuPosition = sum(find(ismember(PSMs,'RADAR')));
			RADARmenuObj = handles.Tables_menu.Children(RADARmenuPosition);
			RADARmenuChObjs = handles.Tables_menu.Children(RADARmenuPosition).Children;
			NumEntriesInRADARmenu = size(RADARmenuChObjs,1);
			
			for i=1:NumEntriesInRADARmenu
				CrntObj = RADARmenuChObjs(i);
				CrntChObj = handles.Tables_menu.Children(RADARmenuPosition).Children(i).Children;
				for ii=1:size(CrntChObj,1)
					CrntObj1 = CrntChObj(ii);
					ThisLBL = CrntObj1.Label;
					CHECKED = logical(sum([strfind(CrntObj1.Checked,char('on')),0]));
					ParentLBL = CrntObj1.Parent.Label;
					PParentLBL = CrntObj1.Parent.Parent.Label;
					if CHECKED
						if exist('CheckList','var')
							CheckList = [CheckList;{PParentLBL,ParentLBL,ThisLBL}];
						else
							CheckList = {PParentLBL,ParentLBL,ThisLBL};
						end
						
					end
				end
			end
		end
		if sum(find(ismember(PSMs,'Table 1')))
			
			TABLE1menuPosition = sum(find(ismember(PSMs,'Table 1')));
			TABLE1menuObj = handles.Tables_menu.Children(TABLE1menuPosition);
			TABLE1menuChObjs = handles.Tables_menu.Children(TABLE1menuPosition).Children;
			NumEntriesInTABLE1menu = size(TABLE1menuChObjs,1);
			
			for i=1:NumEntriesInTABLE1menu
				ParentLBL = TABLE1menuObj.Label;
				ThisLBL = TABLE1menuChObjs(i).Label;
				CHECKED = logical(sum([strfind(TABLE1menuChObjs(i).Checked,char('on')),0]));
				if CHECKED
					if exist('CheckList','var')
						CheckList = [CheckList;{ParentLBL,ThisLBL,''}];
					else
						CheckList = {ParentLBL,ThisLBL,''};
					end
				end
			end
		end
	end
	
	
	if size(TBLMIs,1) > 1
		for i=2:size(TBLMIs,1)
			% disown Source menu item from parent
			set(TBLMIs(i),'Parent',[]);
		end
	end
	
	TBLS = regexprep(regexprep(regexprep(regexprep(regexprep(fieldnames(TABLES),'MID',''),'MPATH',''),'ABLE1','able 1'),'RADAR',''),'STAPP','Stapp Profile');
	RTBLS = regexprep(regexprep(regexprep(fieldnames(TABLES),'MID',''),'MPATH',''),'ABLE1','able 1');
	TBLS(strcmp('',TBLS)) = [];
	RTBLS(strcmp('',TBLS)) = [];
	
	%for i=1:size(TBLS,1)
	%	char(TBLS(i,:));
	%	uimenu(handles.Tables_menu,'Label',char(TBLS(i,:)));
	%end
	if sum(ismember(TBLS,'Table 1'))
		TBL1SubMenu = uimenu(handles.Tables_menu,'Label','Table 1');
		NewMenuItem = uimenu(TBL1SubMenu,'Label','Break Wires','Callback',{@Tables_menu_children_Callback,handles,TABLES});
						if exist('CheckList','var')
							CheckIt = 0;
							for CLi=1:size(CheckList,1)
								CheckIt = CheckIt + (sum(ismember(CheckList(CLi,:),{'Table 1','Break Wires'})) == 2);
							end
							if CheckIt
								NewMenuItem.Checked = 'on';
							end
						end
		
		NewMenuItem = uimenu(TBL1SubMenu,'Label','Fire Boxes','Callback',{@Tables_menu_children_Callback,handles,TABLES});
						if exist('CheckList','var')

							CheckIt = 0;
							for CLi=1:size(CheckList,1)
								CheckIt = CheckIt + (sum(ismember(CheckList(CLi,:),{'Table 1','Fire Boxes'})) == 2);
							end
							if CheckIt
								NewMenuItem.Checked = 'on';
							end
						end
	end
	
	if sum(ismember(TBLS,'Stapp Profile'))
		StappSubMenu = uimenu(handles.Tables_menu,'Label','Stapp Profile');
		NewMenuItem = uimenu(StappSubMenu, 'Label','Stapp stuff','Callback',{@Tables_menu_children_Callback,handles,TABLES});
	end
	
	if sum(ismember(RTBLS,'RADAR'))
		%set(handles.Tables_menu.('RADAR'),'Parent',[])
		RSubMenu = uimenu(handles.Tables_menu,'Label','RADAR');
		RMentries = cellstr(num2str(transpose([1:size(TABLES.RADAR,1)])));
		for i=1:size(TABLES.RADAR,1)
			if ~isempty(TABLES.RADAR{i})
				RME = uimenu(RSubMenu,'Label',char(RMentries(i)));
				if sum(cell2mat(strfind(fieldnames(TABLES.RADAR{i}),'IMPACT')))
					NewMenuItem = uimenu(RME,'Label','Impact','Callback',{@Tables_menu_children_Callback,handles,TABLES});
					if exist('CheckList','var')
						CheckIt = 0;
						for CLi=1:size(CheckList,1)
							CheckIt = CheckIt + (sum(ismember(CheckList(CLi,:),{'RADAR',num2str(i),'Impact'})) == 3);
						end
						if CheckIt
							NewMenuItem.Checked = 'on';
						end
					end
				end
				if sum(cell2mat(strfind(fieldnames(TABLES.RADAR{i}),'PUSHER')))
					NewMenuItem = uimenu(RME,'Label','Pusher','Callback',{@Tables_menu_children_Callback,handles,TABLES});
					if exist('CheckList','var')
						CheckIt = 0;
						for CLi=1:size(CheckList,1)
							CheckIt = CheckIt + (sum(ismember(CheckList(CLi,:),{'RADAR',num2str(i),'Pusher'})) == 3);
						end
						if CheckIt
							NewMenuItem.Checked = 'on';
						end
					end
				end
			end
		end
		%uimenu(handles.Tables_menu,'Label',char('1'))
	end
	
	
	
	
	
	
function updateSources(handles)
	
	PATHTOSRCLOG = get_tmpFilePath('Source.log');
	
	SRCS = utils.files.getSources(PATHTOSRCLOG);
	SRCMIs = findall(handles.SOURCES);
		
	if size(SRCMIs,1) > 1
		for i=2:size(SRCMIs,1)
			% disown Source menu item from parent
			set(SRCMIs(i),'Parent',[]);
		end
	end
	
	for i=1:size(SRCS,1)
		char(SRCS(i,:));
		uimenu(handles.SOURCES,'Label',char(SRCS(i,:)));
	end



% --------------------------------------------------------------------
function Time_Callback(hObject, eventdata, handles)
% hObject    handle to Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Position_Callback(hObject, eventdata, handles)
% hObject    handle to Position (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Reload_Callback(hObject, eventdata, handles)
% hObject    handle to Reload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	VALID = handles.VALID;
	INTPATH = handles.INTPATH;
	if logical(sum(ismember(fieldnames(handles),'TblsMChkdItems')))
		TblsMChkdItems = handles.TblsMChkdItems;
	else
		TblsMChkdItems = '';
	end
		
    if getTable1Path(handles) > 0 & VALID		
        %wholepathfilename = getTable1Path(handles)
		% Load from local copy
		INTPATH.TABLE1.TABLE1;
		wholepathfilename = INTPATH.TABLE1.TABLE1;
		
		if ismember(handles.dnt_fix_stage_vels.Checked,'on')
			VELFIXSTR = 'Dont Fix STG Vels';
		elseif ismember(handles.fix_all_stage_vels.Checked,'on')
			VELFIXSTR = 'Fix All STG Vels';
		elseif ismember(handles.fix_bad_stage_vels.Checked,'on')
			VELFIXSTR = 'Fix Bad STG Vels';
		end
		
        [VALID,TABLES,INTPATH] = import_Table1(wholepathfilename,VELFIXSTR);
    else
        [VALID,TABLES,INTPATH] = import_Table1;
    end
    fclose('all');
	MISSION_ID = TABLES.MID;
	TABLE1_BWs = TABLES.TABLE1.BW;
	TABLE1_FBs = TABLES.TABLE1.FB;
	handles.TABLES = TABLES;
	handles.INTPATH = INTPATH;
	
	% Combine the Selected Table data into one beautiful one line plottable
	% package... ok maybe a couple more lines of code than that
	[FUNCTIONS,STYLES,LEGEND,TBL,TinT] = CombineSelectedTables(TblsMChkdItems,TABLES);
	
	%subplot(20,2,3:2:15);
	%plot(TBL.Time,TBL.TS);
	%handles = guidata(gcbo);
	handles.FUNCTIONS = FUNCTIONS;
	handles.STYLES = STYLES;
	handles.LEGEND = LEGEND;
	handles.TinT = TinT;
	handles.TBL = TBL;
	%handles.PLOTInstrctns = struct('FUNCTIONS',FUNCTIONS, 'STYLES', STYLES, 'LEGEND', LEGEND, 'TinT', TinT)
	handles.TblsMChkdItems = TblsMChkdItems;
	guidata(gcbo,handles);
	
	
	%h = findobj(gca,'Type','line');
	%h = ApplyLineStyles_v1(TBL,TinT,STYLES,h);

	% Turn on the Legend... that's me :)
	%h = legend('show');
	%h.String = LEGEND;
	%h.Location = 'northwest';

	%set(handles.figure1,'toolbar','figure');

		
	if ~VALID
		MISSION_ID = 'Invalid File';
		handles.figure1.Name = MISSION_ID;
		set(handles.MID_field,'String',MISSION_ID);
	else
		handles.figure1.Name = MISSION_ID;
		set(handles.MID_field,'String',horzcat(['Mission ID:','  ',MISSION_ID]));
	end
	updateSources(handles);
	updateTables(handles,INTPATH);

	% Testing to feasability of quicklook view switch
    %updateGraphs(TBL,false,handles);
	VIEW = sum([strfind(handles.quickview_menuitem.Checked,'on');0])+1;
	ViewSwitch(TBL,false,handles,VIEW);
	
	

function [FUNCTIONS,STYLES,LEGEND,TBL,TinT] = CombineSelectedTables(TblsMChkdItems,TABLES)
	ETBLSD = regexprep(regexprep(regexprep(regexprep(regexprep(TblsMChkdItems,'Table 1','TABLE1'),'Fire Boxes','FB'),'Break Wires','BW'),'Impact','IMPACT'),'Pusher','PUSHER');
	RDRD = find(ismember(ETBLSD,'RADAR'));
	TBL1D = find(ismember(ETBLSD,'TABLE1'));
	TBLD = [TBL1D;RDRD];
	RDRD = ETBLSD(RDRD,:);
	TBL1D = ETBLSD(TBL1D,:);
	TBLD = ETBLSD(TBLD,:);
	for i = 1:size(TBLD,1)
		% IMPACT or PUSHER strings in 3rd position are checked
		try
			if ismember(char(TBLD(i,3)),'IMPACT') | ismember(char(TBLD(i,3)),'PUSHER')
				if exist('TBL','var')
					try
						TBL = [TBL,{TABLES.(char(TBLD(i,1))){str2double(TBLD(i,2))}.(char(TBLD(i,3)))}];
					catch e
						TBL = TBL;
					end
				else
					TBL = {TABLES.(char(TBLD(i,1))){str2double(TBLD(i,2))}.(char(TBLD(i,3)))};
				end
			elseif ismember(char(TBLD(i,2)),'BW') | ismember(char(TBLD(i,2)),'FB')
				if exist('TBL','var')
					TBL = [TBL,{TABLES.(char(TBLD(i,1))).(char(TBLD(i,2)))}];
				else
					TBL = {TABLES.(char(TBLD(i,1))).(char(TBLD(i,2)))};
				end
			end
		catch e
			''
		end
	end
	
	if exist('TBL','var')
		% Sort Entries in TBL, so that the Legend doesn't look stupid
		% and this will probably get it's own function
		TinT = max(size(TBL));
		TBLFs = '';
		ROFFS = 0;
		for itmp = 1:TinT
			TBLFs = [TBLFs;TBL{itmp}.Function(1)];
			TBLFs = regexprep(regexprep(regexprep(TBLFs,'RDR_','2 * '),'_IMPACT',' - 1'),'_PUSHER','');
			if ~Match(char(TBLFs(itmp)),'FB-MON') && ~Match(char(TBLFs(itmp)),'First Motion')
			%try
				TBLFs(itmp) = cellstr(num2str(ROFFS + eval(char(TBLFs(itmp)))));
			%catch e
			%	''
			else
				ROFFS = ROFFS + 1;
			end
		end
		TBLwv = TBL;
		%size(TBLFs)
		TBLFints = str2double(TBLFs(ROFFS+1:max(size(TBLFs))));
		TBLFints = TBLFints - (min(TBLFints)-ROFFS-1);
		dTBLFints = [diff([diff(TBLFints);-1]);0];
		dTBLFints1 = [diff(TBLFints);-1];
		TBLFs(ROFFS+1:max(size(TBLFs))) = cellstr(num2str(TBLFints - dTBLFints));
		while max(abs(dTBLFints1))>1
			TBLFints = str2double(TBLFs(ROFFS+1:max(size(TBLFs))));
			TBLFints = TBLFints - (min(TBLFints)-ROFFS-1);
			dTBLFints = [diff([diff(TBLFints);-1]);0];
			dTBLFints1 = [diff(TBLFints);-1];
			TBLFs(ROFFS+1:max(size(TBLFs))) = cellstr(num2str(TBLFints - dTBLFints));
		end

		for itmp = ROFFS+1:TinT
			TBL{itmp} = TBLwv{str2double(TBLFs(itmp))};
		end
		
		
		% equalize table sizes with NaNs, so we can plot them all with no
		% problems
		TBL = utils.TTS.eqWnans(TBL);
		TinT = size(TBL.Function,2); %Tables in TBL
		% Convert Function Strings to Linestyles
		[FUNCTIONS,STYLES,LEGEND] = TBLFunctions_to_LineStyles_v1(TBL,TinT);
	else
		% Something is going to be plotted!
		TinT = 1;
		TBL = TABLES.TABLE1.BW;
		[FUNCTIONS,STYLES,LEGEND] = TBLFunctions_to_LineStyles_v1(TBL,1);
	end
	
	
	
	
	
	
	
	
% --------------------------------------------------------------------
function SOURCES_Callback(hObject, eventdata, handles)
% hObject    handle to SOURCES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function source1_Callback(hObject, eventdata, handles)
% hObject    handle to source1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Tables_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Tables_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function [FUNCTIONS,STYLES,LEGEND] = TBLFunctions_to_LineStyles_v1(TBL,TinT)

	% How many Tables are in TBL
	
	if TinT ~= size(TBL.Function,2)
		TinT = size(TBL.Function,2);
	end

	FUNCTIONS = TBL.Function(1,1:TinT);
	% Convert Function Strings to Linestyles
	%	Anything Breakwire
	STYLES = regexprep(regexprep(regexprep(regexprep(FUNCTIONS,'BreakWires','-r'),'BW-[0-9]','-r'),'BW-[0-9][0-9]','-r'),'First Motion','-r');
	%	FireBoxes
	STYLES = regexprep(regexprep(STYLES,'FB-MON','r>'),'STG-[0-9]','r>');
	%	Anything Impact RDR_1_IMPACT
	STYLES = regexprep(STYLES,'RDR_[0-9]_IMPACT','-b');
	%	Pusher
	STYLES = regexprep(STYLES,'RDR_[0-9]_PUSHER','--g');

	LEGEND = regexprep(regexprep(regexprep(FUNCTIONS,'FB-MON','FireBoxes'),'First Motion','BreakWires'),'_',' ');
	FUNCTIONS = LEGEND;
	
	
% --------------------------------------------------------------------
function FLINS = TBLFunctions_to_LineStyles_v2(TBL,TinT)
% Originally:
%	Breakwires: Red line
%	Fire Boxes: Red Right facing Triangles
%	RADAR Impact:	Blue Line
%	RADAR Pusher:	Green Dashed Line

	% How many Tables are in TBL
	if TinT ~= size(TBL.Function,2)
		TinT = size(TBL.Function,2);
	end	
	
	FUNCTIONS = TBL.Function(1,1:TinT);
	LEGEND = regexprep(regexprep(regexprep(FUNCTIONS,'FB-MON','FireBoxes'),'First Motion','BreakWires'),'_',' ');
	FUNCTIONS = LEGEND;
	FLINS = table();
	FLINS.Legend = transpose(LEGEND);
	FLINS.Color = transpose(...
					regexprep(...
					regexprep(...
					regexprep(...
					regexprep(...
						FUNCTIONS,...
							'FireBoxes',		'Red'	),...
							'BreakWires',		'Red'	),...
							'RDR [0-9] IMPACT',	'Blue'	),...
							'RDR [0-9] PUSHER',	'Green'	));
						
	FLINS.Marker = transpose(...
					regexprep(...
					regexprep(...
					regexprep(...
					regexprep(...
						FUNCTIONS,...
							'FireBoxes',		'square'),...
							'BreakWires',		  '^'	),...
							'RDR [0-9] IMPACT',	  '.'	),...
							'RDR [0-9] PUSHER',	  '.'	));

	FLINS.Style = transpose(...
					regexprep(...
					regexprep(...
					regexprep(...
					regexprep(...
						FUNCTIONS,...
							'FireBoxes',		'none'),...
							'BreakWires',		'none'),...
							'RDR [0-9] IMPACT',	'none'),...
							'RDR [0-9] PUSHER',	'none'));


	FLINS.MarkerSize = transpose(...
					regexprep(...
					regexprep(...
					regexprep(...
					regexprep(...
						FUNCTIONS,...
							'FireBoxes',		'8'),...
							'BreakWires',		'8'),...
							'RDR [0-9] IMPACT',	'15'),...
							'RDR [0-9] PUSHER',	'15'));
						
	FLINS.MarkerSize = str2double(FLINS.MarkerSize);
	

% --------------------------------------------------------------------
function h = ApplyLineStyles_v1(TBL,TinT,STYLES,h)
	
	for i=1:TinT;
		%indexes are backwards
		ii = TinT - i + 1;
		try
			FLS = char(regexprep(regexprep(STYLES(ii),'[a-z]',''),'>',''));
			if ~isempty(FLS)
				h(i).LineStyle = FLS;
			else
				h(i).LineStyle = 'none';
			end
			FLC = char(regexprep(regexprep(STYLES(ii),'>',''),'-',''));
			if ~isempty(FLC)
				h(i).Color = FLC;
			end
			FLM = char(regexprep(regexprep(STYLES(ii),'-',''),'[a-z]',''));
			if ~isempty(FLM)
				h(i).Marker = FLM;
			end
			
		catch e
			e.message;
		end
	end
		

	
	
	
% --------------------------------------------------------------------
function [h,handles] = ApplyLineStyles_v2(TBL,FLINS,h,handles)

	TinT = size(FLINS,1);
	
	for i=1:TinT;
		%indexes are backwards
		ii = TinT - i + 1;
		try
			h(i).LineStyle = char(FLINS.Style(ii));
			h(i).Color = char(FLINS.Color(ii));
			
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			% if there's more than one of the same color/function
			FQ = sum(ismember(FLINS.Color,FLINS.Color(ii)));
			FSN = find(find(ismember(FLINS.Color,FLINS.Color(ii))) == ii);
			%CFS = 1
			%COS = 0.3
			h(i).Color(find(ismember(transpose(h(i).Color),1))) = .5 + (FSN * (.5 / FQ));
			%h(i).Color(find(ismember(transpose(h(i).Color),1))) = 1 - (FSN * (.4 / FQ))
			%h(i).Color(find(ismember(transpose(h(i).Color),1))) = CFS - (FSN * (COS / FQ));
			%h(i).Color
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
			h(i).Marker = char(FLINS.Marker(ii));
			h(i).MarkerSize = FLINS.MarkerSize(ii);
		catch e
			e.message;
		end
	end
	
	% Stuff to figure size and position of the legend and text box
	lgnd = legend('show');
	lgnd.String = transpose(FLINS.Legend);
	lgnd.Location = 'northeast';
	%lgnd.Position(1) = lgnd.Position(1) - 0.012
	%lgnd.Position(2) = lgnd.Position(2) - lgnd.Position(4) - 0.08
	
	
	% We want specificically RADARs.
	% Even more specifically, so that redundant data isn't shown, the impact
	% file is preferred.
	% And... We want all RADAR Max/Impact Velocities
	ACCSRCS = 'IMPACT';
	MxImp = What_MxImp_Vels(TBL,ACCSRCS);
	MAXV = char(num2str(round(max(max(MxImp.Velocity(1))),3)));
	IMPV = char(num2str(round(max(max(MxImp.Velocity(2))),3)));
	MAXVtim = regexprep(char(MxImp.DateTime(1)),'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ','');
	IMPVtim = regexprep(char(MxImp.DateTime(2)),'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ','');
	MAXVowner = char(MxImp.Function(1));
	IMPVowner = char(MxImp.Function(2));
	
	
	STR = horzcat(h.DisplayName);
	STR = utils.misc.strsplit(...
			char(...
				regexprep(...
				regexprep(...
				regexprep(...
				regexprep(...
					STR,'IMPACT',	'IMPACT\t'),...
						'PUSHER',	'PUSHER\t'),...
						'Wires',	'Wires\t'),...
						'Boxes',	'Boxes\t')),'\t');
	
	% This will be kind of like building the string to decode certain infrared signals
	% Max and Impact file source Quantity
	MIVfQ = size(MxImp.Velocity(1,:),2);
	
	% Max Vel heading
	MIVTxtBxStr =	 cellstr(horzcat('MAX VELOCITY: ','','','','','','',''));
	% Add Max velocities
	ioff = 1;

	
	for i=1:MIVfQ
		% Building the strings for building the strings
		MAXV = char(num2str(round(MxImp.Velocity(1,i),3)));
		MAXVtim = char(DateTimeRound(MxImp.DateTime(1,i),3,true));
		MAXVowner = char(MxImp.Function(1,i));

		%Maybe this whole section needs it's own function
		%extract assigned color from the legend to assign the owner text a
		%color
		% translate convert RADAR # to RDR # IMPACT, if not BW#
		if ~ismember(MAXVowner,'BW')
			MAXVownerlgndname = strcat(regexprep(MAXVowner,'RADAR','RDR'),' IMPACT');
		else
			MAXVownerlgndname = 'BreakWires';
		end
		
		lpos = find(ismember(STR,MAXVownerlgndname));
		PUSHOnly = false;
		if isempty(lpos)
			MAXVownerlgndname = regexprep(MAXVowner,'RADAR','RDR');
			lpos = find(ismember(STR,MAXVownerlgndname));
			MAXVowner = regexprep(MAXVowner,'PUSHER','');
			PUSHOnly = true;
		end
		
		

		if ~isempty(lpos)
			COLOR = h(lpos).Color;
		else
			lpos = 1;
			COLOR = h(lpos).Color;
		end
		
		%Now, how do I apply this color to this new legend
		MAXVowner = sprintf('{\\color[rgb]{%f,%f,%f} %s}',COLOR(1),COLOR(2),COLOR(3),MAXVowner);
		MIVTxtBxStr(i+ioff) = cellstr(horzcat('    ',MAXVowner,': ',MAXV,' ft/s','   ','@ ',MAXVtim));
	end
	ioff = i + ioff + 1;
	MIVTxtBxStr(ioff) = cellstr(horzcat('','','','','','','',''));
	ioff = ioff + 1;
	if ~PUSHOnly
		MIVTxtBxStr(ioff) = cellstr(horzcat('IMPACT VELOCITY: ','','','','','','',''));
		for i=1:MIVfQ
			IMPV = char(num2str(round(MxImp.Velocity(2,i),3)));
			IMPVtim = char(DateTimeRound(MxImp.DateTime(2,i),3,true));
			IMPVowner = char(MxImp.Function(2,i));
		
		%Maybe this whole section needs it's own function
		%extract assigned color from the legend to assign the owner text a
		%color
		% translate convert RADAR # to RDR # IMPACT, if not BW#
			if ~ismember(MAXVowner,'BW')
				IMPVownerlgndname = strcat(regexprep(IMPVowner,'RADAR','RDR'),' IMPACT');
			else
				IMPVownerlgndname = 'BreakWires';
			end


			lpos = find(ismember(STR,IMPVownerlgndname));

			if ~isempty(lpos)
				COLOR = h(lpos).Color;
			else
				lpos = 1;
				COLOR = h(lpos).Color;
			end
		
		%Now, how do I apply this color to this new legend
			IMPVowner = sprintf('{\\color[rgb]{%f,%f,%f} %s}',COLOR(1),COLOR(2),COLOR(3),IMPVowner);
		
			MIVTxtBxStr(i+ioff) = cellstr(horzcat('    ',IMPVowner,': ',IMPV,' ft/s','  ','@ ',IMPVtim));
		end
	end

	
	plt = findall(gca,'type','axes');
	pltxlim = plt.XLim;
	pltylim = plt.YLim;
	%plt.Position(1) = plt.Position(1)*0.5
	%plt.Position(3) = plt.Position(3)*1.15
	pltpos = plt.Position;
	%plt.XTickLabelRotation = 45
	plt.FontSize = 12;
	plt.FontWeight = 'bold';
	
	plt.Title.FontUnits = 'normalized';
	plt.Title.FontSize = 0.05;
	plt.Title.Units = 'normalized';
	while plt.Title.Position(2) < 4/5
		plt.Title.Position;
		plt.Title.FontSize = plt.Title.FontSize + 0.02;
	end
	
	% Axis Labels 9/10 of Title
	plt.XLabel.FontUnits = 'normalized';
	plt.YLabel.FontUnits = 'normalized';
	plt.XLabel.FontSize = 9 * plt.Title.FontSize / 10;
	plt.YLabel.FontSize = 9 * plt.Title.FontSize / 10;
	
	
	plt.YLabel.FontUnits ='points';
	lgnd.FontSize = 7 * plt.YLabel.FontSize / 10;
	plt.YLabel.FontUnits ='normalized';
	lgnd.FontUnits = 'normalized';
	
	plt.Title.FontWeight = 'bold';
	plt.XLabel.FontWeight = 'bold';
	plt.YLabel.FontWeight = 'bold';
	
	plt.TickLength = plt.TickLength * 2;

	plt.YLabel.Units = 'normalized';
	plt.Units = 'normalized';
	nnpylp = plt.Position(1)+plt.YLabel.Extent(1)/(1/plt.Position(3));
	if	nnpylp < 0.4
		plt.Position(1) = plt.Position(1) - nnpylp + 0.01;
		nnpylp = plt.Position(1)+plt.YLabel.Extent(1)/(1/plt.Position(3));
	elseif nnpylp > 0.4
		plt.Position(1) = plt.Position(1) - nnpylp + 0.51;
		nnpylp = plt.Position(1)+plt.YLabel.Extent(1)/(1/plt.Position(3));
	end
	if plt.Position(3) < 0.5
		LEFT = plt.Position(1) < 0.5;
		plt.Position(1);
		RIGHT = ~LEFT;
		if LEFT
			plt.Position(3) = 0.49 - plt.Position(1);
		elseif RIGHT
			plt.Position;
			plt.Position(3) = 0.99 - plt.Position(1);
		end
	elseif plt.Position(3) > 0.5
		plt.Position(1) + plt.Position(3);
		plt.Position(3) = 0.99 - plt.Position(1);
	end
	
	[plt,lgnd] = FixLgndPos(TBL);
    %editing here
    [plt,lgnd2] = FixLgnd2Pos(TBL,MIVTxtBxStr,MxImp);


	title(handles.MID_field.String);
	
		

% --------------------------------------------------------------------
function Rounded_DateTime =  DateTimeRound(DATETIME,i,RMDATE)

	
	dtwv = char(DATETIME);
	if RMDATE
		dtwv = regexprep(dtwv,'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] ','');
	end
	% 1.) Split at the colons
	Splittime = utils.misc.strsplit(dtwv,':');
	if ~isempty(Splittime)
		RnddSECs = str2double(Splittime(3));
		fstr = strcat('%','0',num2str(round(size(char(Splittime(3)),2)-i)),'.',num2str(i),'f');
		SECS = sprintf(fstr,RnddSECs);
	else
		SECS = '0';
	end
	
	
	
	
	Rounded_DateTime = regexprep(dtwv,'[0-9][0-9].[0-9][0-9][0-9][0-9][0-9][0-9]',SECS);
	
		
% --------------------------------------------------------------------
function Tables_menu_children_Callback(hObject,eventdata,handles,TABLES)
% hObject    handle to Tables_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



PM = get(hObject,'Parent');
PPM = get(PM,'Parent');
CM = hObject;

TblsMChkdItems = '';
%[PPM.Label,PM.Label,CM.Label];


	if ismember(PM.Label,cellstr('Table 1'))
	
		if ismember(CM.Checked,'off')
			CM.Checked = 'on';
		else
			CM.Checked = 'off';
		end
	
	
	elseif ismember(PPM.Label,cellstr('RADAR'))
	
		if ismember(CM.Checked,'off')
			CM.Checked = 'on';
			i = str2double(char(PM.Label));
			CMSE = regexprep(regexprep(CM.Label,'Impact','IMPACT'),'Pusher','PUSHER');
		else
			CM.Checked = 'off';
		end

	end
	
	% Find Menu Root
	if ismember(CM.Parent.Label,'Tables')
		TMROOT = CM.Parent;
	elseif ismember(CM.Parent.Parent.Label,'Tables')
		TMROOT = CM.Parent.Parent;
	elseif ismember(CM.Parent.Parent.Parent.Label,'Tables')
		TMROOT = CM.Parent.Parent.Parent;
	end
	ITEMS = findall(TMROOT.Children);
	
	for i=1:size(ITEMS,1)
		if ismember(ITEMS(i).Checked,'on')
			if ~ismember(ITEMS(i).Parent.Label,TMROOT.Label)
				if ~ismember(ITEMS(i).Parent.Parent.Label,TMROOT.Label)
					ARR = [...
							cellstr(ITEMS(i).Parent.Parent.Label),...
							cellstr(ITEMS(i).Parent.Label)...
							cellstr(ITEMS(i).Label)...
						];
				else
					ARR = [...
							cellstr(ITEMS(i).Parent.Label)...
							cellstr(ITEMS(i).Label)...
							cellstr('')...
						];
				end
			else
				ARR = [...
						cellstr(ITEMS(i).Parent.Label)...
						cellstr(ITEMS(i).Label)...
						cellstr('')...
						];
			end
			TblsMChkdItems = [TblsMChkdItems;ARR];
		end
	end
	handles = guidata(gcbo);
	handles.TblsMChkdItems = TblsMChkdItems;
	guidata(gcbo,handles);
	Reload_Callback(hObject, eventdata, handles);
	


% --------------------------------------------------------------------
function	VELS = What_MxImp_Vels(TABLE,ACCSRCS)
% returns Table Velocity information.....


	AVAILSRCS = regexprep(regexprep(TABLE.Function(1,:),'RDR_[1-9]_',''),...
				'First Motion', 'Breakwires');
			
	% Default Acceptable Sources of Impact/Peak Velocity to the only
	% available data source => based on what is already pre-selected
	if size(cellstr(AVAILSRCS),2) == 1
		ACCSRCS = AVAILSRCS;
	end
	% Source columns that contain the acceptable source\
	SRCCOL = find(ismember(AVAILSRCS,ACCSRCS));
	if isempty(SRCCOL)
		ACCSRCS = 'Breakwires';
		SRCCOL = find(ismember(AVAILSRCS,ACCSRCS));
	end
	if isempty(SRCCOL)
		ACCSRCS = 'PUSHER';
		
		SRCCOL = find(ismember(AVAILSRCS,ACCSRCS));
	end
	
	% Max Velocity of all sources
	MAXVELS = max(TABLE.Velocity)
	% Supposed times of impact max(t)
	TOIt = max(TABLE.Time)
	%TOIDt = max(TABLE.DateTime)
	
	for ASCNTF=1:size(SRCCOL,2)
		MAXVELS_IND(ASCNTF) = transpose(find(ismember(TABLE.Velocity(:,SRCCOL(ASCNTF)),MAXVELS)))
		IMPVELS_IND(ASCNTF) = transpose(find(ismember(TABLE.Time(:,SRCCOL(ASCNTF)),TOIt)))
	end
	

	for ASCNTF=1:size(SRCCOL,2)
		MAXVELS1(ASCNTF) = MAXVELS(SRCCOL(ASCNTF));
		MAXVEL_Func(ASCNTF) = TABLE.Function(MAXVELS_IND(ASCNTF),SRCCOL(ASCNTF));
		MAXVEL_Time(ASCNTF) = TABLE.Time(MAXVELS_IND(ASCNTF),SRCCOL(ASCNTF));
		MAXVEL_DatTim(ASCNTF) = TABLE.DateTime(MAXVELS_IND(ASCNTF),SRCCOL(ASCNTF));
		
		IMPVELS(ASCNTF) = TABLE.Velocity(IMPVELS_IND(ASCNTF),SRCCOL(ASCNTF));
		IMPVEL_Func(ASCNTF) = TABLE.Function(IMPVELS_IND(ASCNTF),SRCCOL(ASCNTF));
		IMPVEL_DatTim(ASCNTF) = TABLE.DateTime(IMPVELS_IND(ASCNTF),SRCCOL(ASCNTF));
		IMPVEL_Time(ASCNTF) = TABLE.Time(IMPVELS_IND(ASCNTF),SRCCOL(ASCNTF));
	end
	try
		MAXVELS = table(MAXVEL_Func,MAXVELS1,MAXVEL_Time,MAXVEL_DatTim);
		IMPVELS = table(IMPVEL_Func,IMPVELS,IMPVEL_Time,IMPVEL_DatTim);
	catch e
		MAXVELS = table(cellstr('None'),0,0,0);
		IMPVELS = table(cellstr('None'),0,0,0);
	end
	
	
	MAXVELS.Properties.VariableNames = {'Function' 'Velocity' 'Time' 'DateTime'};
	IMPVELS.Properties.VariableNames = {'Function' 'Velocity' 'Time' 'DateTime'};
	
	VELS = [MAXVELS;IMPVELS];
	VELS.Function = regexprep(...
				   regexprep(...
				   regexprep(...
						VELS.Function,'RDR','RADAR')...
							,'_IMPACT','')...
							,'_',' ');


% --------------------------------------------------------------------
function SaImpZoom_Callback(hObject, eventdata, handles)
% hObject    handle to SaImpZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	
	if sum([strfind(hObject.Checked,'off');0]);
		hObject.Checked = 'on';
		handles.quickview_menuitem.Checked = 'on';
		handles.SaNoZoom.Checked = 'off';
	elseif sum([strfind(hObject.Checked,'on');0]);
		hObject.Checked = 'off';
		handles.SaNoZoom.Checked = 'off';
	end;
	
	Reload_Callback(hObject, eventdata, handles);
	
	
	
% --------------------------------------------------------------------
function SaNoZoom_Callback(hObject, eventdata, handles)
% hObject    handle to SaNoZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	if sum([strfind(hObject.Checked,'off');0]);
		hObject.Checked = 'on';
		handles.quickview_menuitem.Checked = 'on';
		handles.SaImpZoom.Checked = 'off';
	elseif sum([strfind(hObject.Checked,'on');0]);
		hObject.Checked = 'off';
		handles.SaImpZoom.Checked = 'off';
	end;
	
	Reload_Callback(hObject, eventdata, handles);
	
	
	


% --------------------------------------------------------------------
function exportimg_Callback(hObject, eventdata, handles)
% hObject    handle to exportimg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if sum([strfind(handles.SaImpZoom.Checked,'on');0]);
        IMGFILNAM = strcat(char(handles.TABLES.MID),'_Zoomed_Impact_Time.png');
        IMGFILNAM2 = strcat(char(handles.TABLES.MPATH),char(handles.TABLES.MID),'_Zoomed_Impact_Time.png');
		%IMGFILNAM3 = strcat(char(handles.TABLES.MPATH),char(handles.TABLES.MID),'_Zoomed_Impact_Time.eps');
    elseif sum([strfind(handles.SaNoZoom.Checked,'on');0]);
        IMGFILNAM = strcat(char(handles.TABLES.MID),'_Pusher_Impact_Whole.png');
        IMGFILNAM2 = strcat(char(handles.TABLES.MPATH),char(handles.TABLES.MID),'_Pusher_Impact_Whole.png');
		%IMGFILNAM3 = strcat(char(handles.TABLES.MPATH),char(handles.TABLES.MID),'_Pusher_Impact_Whole.eps');
    else
        IMGFILNAM = strcat(char(handles.TABLES.MID),'.png');
        IMGFILNAM2 = strcat(char(handles.TABLES.MPATH),char(handles.TABLES.MID),'.png');
		%IMGFILNAM3 = strcat(char(handles.TABLES.MPATH),char(handles.TABLES.MID),'.eps');
    end
    set(gcf,'paperpositionmode','auto');
    
    try
        print('-dpng','-r400',IMGFILNAM2);
        fclose('all')
		%print('-depsc2',IMGFILNAM3);
    catch e
        %'There was a problem, so I saved it here'
        %IMGFILNAM
        print('-dpng','-r400',IMGFILNAM);
        fclose('all')
    end
    
    
function [plt,lgnd2] = FixLgnd2Pos(TBL,MIVTxtBxStr,MxImp)

    try
        MAXVEL = sum(max(MxImp.Velocity))/size(max(MxImp.Velocity),2);
        IMPVEL = sum(min(MxImp.Velocity))/size(min(MxImp.Velocity),2);
        MAXVELT = sum(min(MxImp.Time))/size(min(MxImp.Time),2);
        IMPVELT = sum(max(MxImp.Time))/size(max(MxImp.Time),2);
    catch e
        MAXVEL = max(MxImp.Velocity);
        IMPVEL = min(MxImp.Velocity);
        MAXVELT = min(MxImp.Time);
        IMPVELT = max(MxImp.Time);
    end
    
    plt = findall(gca,'type','axes');

    lgnd = legend('show');
    lgnd.FontUnits = 'points';
    
    %initial placement of the secondary legend, based on being zoomed to
    %impact, and displaying Pusher data or not 
    
    DISPPUSH = sum([cell2mat(strfind(strcat(TBL.Function(1,:)),'PUSHER')),0]) > 0;
    ZOOMED = sum(sum(TBL.Time < plt.XLim(1))) > 0;
    if ~ZOOMED && DISPPUSH
        lgnd2 = text(IMPVELT,IMPVEL/2,MIVTxtBxStr,	'Units',        'data',...
                                    'FontUnits',    'points',...
                                    'FontSize',     lgnd.FontSize * 0.75,...
                                    'FontWeight',   'bold');
        
    elseif ~ZOOMED && ~DISPPUSH
        lgnd2 = text(plt.XLim(1) + abs(diff(plt.XLim)*3/100),IMPVEL/2,MIVTxtBxStr,	'Units',        'data',...
                                    'FontUnits',    'points',...
                                    'FontSize',     lgnd.FontSize * 0.75,...
                                    'FontWeight',   'bold');
    else
        lgnd2 = text(0,0,MIVTxtBxStr,	'Units',        'normalized',...
                                    'FontUnits',    'points',...
                                    'FontSize',     lgnd.FontSize * 0.75,...
                                    'FontWeight',   'bold');
        set(lgnd2,'Units','data');
    
        % adjust position of secondary legend so its entirely inside the axis
        % window
            %it will be half below axis and half above the lower axis window
            %limit
        txtbxos = plt.YLim(1) - lgnd2.Extent(2);
        % 3% of total x & y Limit spans
        lgnd2.Position(2) = lgnd2.Position(2) + txtbxos + (abs(diff(plt.YLim)) * (3/100));
        lgnd2.Position(1) = lgnd2.Position(1) + (abs(diff(plt.XLim)) * (3/100));
    end
    
    
    %What Data points are inside the secondary legend boundaries?
        % 1.) Where are the boundaries?
            % lower left; upper right
            % (1,1) time lower left corner
            % (1,2) velocity lower left corner
            % (2,1) time upper right corner
            % (2,2) velocity upper right corner
            EXTENT = get(lgnd2,'Extent');
            lgnd2bxbnds(1,1:2) = EXTENT(1:2);
            lgnd2bxbnds(2,1:2) = EXTENT(1:2) + EXTENT(3:4);

            % 2.) Now What data is inside that box
            GTL = TBL.Time >= lgnd2bxbnds(1,1) & TBL.Velocity >= lgnd2bxbnds(1,2);
            LTR = TBL.Time <= lgnd2bxbnds(2,1) & TBL.Velocity <= lgnd2bxbnds(2,2);
            INSIDE = GTL & LTR;
            
            while sum(sum(INSIDE))>0 && ~ZOOMED
                lgnd2.Position(1) = lgnd2.Position(1) + abs(diff(plt.XLim))*(1/100);
                EXTENT = get(lgnd2,'Extent');
                lgnd2bxbnds(1,1:2) = EXTENT(1:2);
                lgnd2bxbnds(2,1:2) = EXTENT(1:2) + EXTENT(3:4);

                % 2.) Now What data is inside that box
                GTL = TBL.Time >= lgnd2bxbnds(1,1) & TBL.Velocity >= lgnd2bxbnds(1,2);
                LTR = TBL.Time <= lgnd2bxbnds(2,1) & TBL.Velocity <= lgnd2bxbnds(2,2);
                INSIDE = GTL & LTR;
            
			end
			
            if ~ZOOMED && ~DISPPUSH
                % Center the Secondary Legend between Impact Time and Where
                % it currently is.  There should be a data point just
                % outside the NW corner
                MPC = (IMPVELT + lgnd2.Extent(1))/2;
                LMPC = lgnd2.Extent(1) + (lgnd2.Extent(3)/2);
                lgnd2.Position(1) = lgnd2.Extent(1) + MPC - LMPC;
            elseif ~ZOOMED && DISPPUSH
                MAXTIM = max(max(TBL.Time));
                MPC = (MAXTIM + IMPVELT)/2;
                LMPC = lgnd2.Extent(1) + (lgnd2.Extent(3)/2);
                lgnd2.Position(1) = lgnd2.Extent(1) + MPC - LMPC;
			end
			    %What Data points are inside the secondary legend boundaries?
        % 1.) Where are the boundaries?
            % lower left; upper right
            % (1,1) time lower left corner
            % (1,2) velocity lower left corner
            % (2,1) time upper right corner
            % (2,2) velocity upper right corner
            EXTENT = get(lgnd2,'Extent');
            lgnd2bxbnds(1,1:2) = EXTENT(1:2);
            lgnd2bxbnds(2,1:2) = EXTENT(1:2) + EXTENT(3:4);
			
            % 2.) Now What data is inside that box
            GTL = TBL.Time >= lgnd2bxbnds(1,1) & TBL.Velocity >= lgnd2bxbnds(1,2);
            LTR = TBL.Time <= lgnd2bxbnds(2,1) & TBL.Velocity <= lgnd2bxbnds(2,2);
            INSIDE = GTL & LTR;
			OUTSIDE = lgnd2.Extent(1) + lgnd2.Extent(3) > plt.XLim(2);

			while sum(sum(INSIDE))>0 && ZOOMED
				EXTENTwnt = get(lgnd2,'Extent');
				lgnd2.FontSize = lgnd2.FontSize * 0.8;
				lgnd.FontSize = lgnd.FontSize * 0.8;				
				EXTENT = get(lgnd2,'Extent');
				lgnd2.Position(2) = lgnd2.Position(2) + EXTENTwnt(2)-EXTENT(2);
				EXTENT = get(lgnd2,'Extent');
				lgnd2bxbnds(1,1:2) = EXTENT(1:2);
				lgnd2bxbnds(2,1:2) = EXTENT(1:2) + EXTENT(3:4);
				GTL = TBL.Time >= lgnd2bxbnds(1,1) & TBL.Velocity >= lgnd2bxbnds(1,2);
				LTR = TBL.Time <= lgnd2bxbnds(2,1) & TBL.Velocity <= lgnd2bxbnds(2,2);
				INSIDE = GTL & LTR;
			end
			
			while sum(sum(INSIDE))>0 && ~ZOOMED

				EXTENT = get(lgnd2,'Extent');
				%Legend Mid Point that we want
				LMPCwnt = EXTENT(1) + (EXTENT(3)/2);
				
				lgnd2.FontSize = lgnd2.FontSize * 0.8;
				lgnd.FontSize = lgnd.FontSize * 0.8;

				
				plt.YLim(2) = MAXVEL+abs(diff(plt.YLim))*(3/100);
				plt.XLim(2) = max(max(TBL.Time)) + abs(diff(plt.XLim))*(3/100);
				[plt,lgnd] = FixLgndPos(TBL);
				
				EXTENT = get(lgnd2,'Extent');
				%Legend Mid Point that we want
				LMPCcur = EXTENT(1) + (EXTENT(3)/2);
				
				lgnd2.Position(1) = EXTENT(1) + LMPCwnt - LMPCcur;
	            
				EXTENT = get(lgnd2,'Extent');
				lgnd2bxbnds(1,1:2) = EXTENT(1:2);
		        lgnd2bxbnds(2,1:2) = EXTENT(1:2) + EXTENT(3:4);
				
				% 2.) Now What data is inside that box
				GTL = TBL.Time >= lgnd2bxbnds(1,1) & TBL.Velocity >= lgnd2bxbnds(1,2);
				LTR = TBL.Time <= lgnd2bxbnds(2,1) & TBL.Velocity <= lgnd2bxbnds(2,2);
				INSIDE = GTL & LTR;
				OUTSIDE = lgnd2.Extent(1)+lgnd2.Extent(3) > plt.XLim(2);
            end
            % 3.) What quadrant of secondary legend are those data points
                %     mostly in?
            %lgnd2tmp = lgnd2bxbnds(1,1) + (lgnd2bxbnds(2,1) - lgnd2bxbnds(1,1))/2;
            %lgnd2vmp = lgnd2bxbnds(1,2) + (lgnd2bxbnds(2,2) - lgnd2bxbnds(1,2))/2;
            %NorthHalf = INSIDE & TBL.Velocity > lgnd2vmp;
            %EastHalf = INSIDE & TBL.Time > lgnd2tmp;
            %WestHalf = INSIDE & ~EastHalf;
            %SouthHalf = INSIDE & ~NorthHalf;
            %NWQuad = INSIDE & WestHalf & NorthHalf;
            %NEQuad = INSIDE & EastHalf & NorthHalf;
            %SEQuad = INSIDE & EastHalf & SouthHalf;
            %SWQuad = INSIDE & WestHalf & SouthHalf;
            
            %E_N = sum([sum(sum(NorthHalf)),0]);
            %E_NE = sum([sum(sum(NEQuad)),0]);
            %E_E = sum([sum(sum(EastHalf)),0]);
            %E_SE = sum([sum(sum(SEQuad)),0]);
            %E_S = sum([sum(sum(SouthHalf)),0]);
            %E_SW = sum([sum(sum(SWQuad)),0]);
            %E_W = sum([sum(sum(WestHalf)),0]);
            %E_NW = sum([sum(sum(NWQuad)),0]);
            
            %E_N = (E_NW + E_NE)/2;
            %E_E = (E_NE + E_SE)/2;
            %E_S = (E_SE + E_SW)/2;
            %E_W = (E_SW + E_NW)/2;
            
            %WORSTDIRtMV = [E_N,E_NE,E_E,E_SE,E_S,E_SW,E_W,E_NW]
            %WDtMvind = find(max(max(WORSTDIRtMV)) == WORSTDIRtMV)
            %WORSTDIRtMV(WDtMvind)
    
function [plt,lgnd] = FixLgndPos(TBL)

	plt = findall(gca,'type','axes');
	lgnd = legend('show');
    
    dfb =  (plt.Position(1:2)  +  plt.Position(3:4)) - ...
           (lgnd.Position(1:2) + lgnd.Position(3:4));
    
    %legend buffered position
    lgndbpos = lgnd.Position(1:2) - dfb;
    
    nrmdVel = ((TBL.Velocity - plt.YLim(1)) * plt.Position(4) / diff(plt.YLim)) + plt.Position(2);
    nrmdTim = ((TBL.Time - plt.XLim(1)) * plt.Position(3) / diff(plt.XLim)) + plt.Position(1);
    INTERSECT = sum(sum((nrmdVel > lgndbpos(2)) & (nrmdTim > lgndbpos(1)))) > 0;
    
    
    while INTERSECT
        plt.YLim = plt.YLim * 1.01;
        %plt.XLim = plt.XLim * 1.001;

        dfb =  (plt.Position(1:2)  +  plt.Position(3:4)) - ...
              (lgnd.Position(1:2)  + lgnd.Position(3:4));
    
        %legend buffered position
        lgndbpos = lgnd.Position(1:2) - dfb;
    
        nrmdVel = ((TBL.Velocity - plt.YLim(1)) * plt.Position(4) / diff(plt.YLim)) + plt.Position(2);
        nrmdTim = ((TBL.Time - plt.XLim(1)) * plt.Position(3) / diff(plt.XLim)) + plt.Position(1);
        INTERSECT = sum(sum((nrmdVel > lgndbpos(2)) & (nrmdTim > lgndbpos(1)))) > 0;
    end


% --------------------------------------------------------------------
function misc_opts_Callback(hObject, eventdata, handles)
% hObject    handle to misc_opts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function fix_bad_stage_vels_Callback(hObject, eventdata, handles)
% hObject    handle to fix_bad_stage_vels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	if ismember(handles.fix_bad_stage_vels.Checked,'off')
		handles.fix_bad_stage_vels.Checked = 'on';
		handles.fix_all_stage_vels.Checked = 'off';
		handles.dnt_fix_stage_vels.Checked = 'off';
	else
		handles.fix_bad_stage_vels.Checked = 'off';
		handles.fix_all_stage_vels.Checked = 'off';
		handles.dnt_fix_stage_vels.Checked = 'on';
	end
	
	Reload_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function fix_all_stage_vels_Callback(hObject, eventdata, handles)
% hObject    handle to fix_all_stage_vels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	if ismember(handles.fix_all_stage_vels.Checked,'off')
		handles.fix_bad_stage_vels.Checked = 'off';
		handles.fix_all_stage_vels.Checked = 'on';
		handles.dnt_fix_stage_vels.Checked = 'off';
	else
		handles.fix_bad_stage_vels.Checked = 'off';
		handles.fix_all_stage_vels.Checked = 'off';
		handles.dnt_fix_stage_vels.Checked = 'on';
	end
	
	Reload_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function dnt_fix_stage_vels_Callback(hObject, eventdata, handles)
% hObject    handle to dnt_fix_stage_vels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	if ismember(handles.dnt_fix_stage_vels.Checked,'off')
		handles.fix_bad_stage_vels.Checked = 'off';
		handles.fix_all_stage_vels.Checked = 'off';
		handles.dnt_fix_stage_vels.Checked = 'on';
	else
		handles.fix_bad_stage_vels.Checked = 'off';
		handles.fix_all_stage_vels.Checked = 'on';
		handles.dnt_fix_stage_vels.Checked = 'off';
	end
	
	Reload_Callback(hObject, eventdata, handles);
	


% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	%selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    %                 ['Close ' get(handles.figure1,'Name') '...'],...
    %                 'Yes','No','Yes');
	%if strcmp(selection,'No')
	%	return;
	%end

	delete(handles.figure1);
