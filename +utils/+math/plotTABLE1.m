function axislbls = plotTABLE1(TABLE1,x,y)


    axislbls = cell(1,2);
    
    if nargin < 3 && nargin >= 1
        x = 't';
        y = 'p';
    end
        
    if nargin == 0
        return;
        
    elseif nargin >= 1

        TABLE1.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity' 'DateTime'};

        clear gca;
        axis = gca;
        
        

        if logical(strfind(x,'P')) | logical(strfind(x,'ts')) | logical(strfind(x,'TS'))
            xlbl = 'Position (absolute)';
            x = TABLE1.TS;
                            
        elseif logical(strfind(x,'p')) | logical(strfind(x,'D')) | logical(strfind(x,'d'))
            xlbl = 'Position (relative)';
            x = cumsum(diff([TABLE1.TS(1,:);TABLE1.TS]));
            if TABLE1.TS(3)<TABLE1.TS(2)
                x = (-1) * x;
			end
			
        elseif logical(strfind(x,'T'))
            xlbl = 'Time (absolute)';
            x = TABLE1.DateTime;
            
        elseif logical(strfind(x,'BW'))
            xlbl = 'BW';
			TABLE1 = shrink4BWs(TABLE1);
            %x = (1:size(TABLE1,1)) - 1;
            x = str2double(TABLE1.Function);
			
        elseif logical(strfind(x,'v')) | logical(strfind(x,'V'))
            xlbl = 'Velocity';
            x = TABLE1.Velocity;
            
        elseif logical(strfind(x,'t'))
            xlbl = 'Time (relative)';
			x = TABLE1.Time;
        end
    
        if logical(strfind(y,'P')) | logical(strfind(y,'ts')) | logical(strfind(y,'TS'))
            ylbl = 'Position (absolute)';
            y = TABLE1.TS;
        
        elseif (logical(strfind(y,'v')) | logical(strfind(y,'V')))
            ylbl = 'Velocity';
            y = TABLE1.Velocity;
            
        elseif (logical(strfind(y,'p')) | logical(strfind(y,'D')) | logical(strfind(y,'d')))
            ylbl = 'Position (relative)';
			y = cumsum(diff([TABLE1.TS(1,:);TABLE1.TS]));
			
            if TABLE1.TS(3)<TABLE1.TS(2)
                y = (-1) * y;
            end
            
        elseif logical(strfind(y,'BW'))
            ylbl = 'BW';
			
			% Here is where I'm playing, for now
			%	Translate Stages to Breakwire Numbers.
			%	Considering that their information is
			%	already in the same format, TS and Time are as they are.
			TABLE1 = shrink4BWs(TABLE1);
			x = reAssign_X_axis(xlbl,TABLE1);
			%y = (1:size(TABLE1,1)) - 1;
			% Here's the new s***!!!!
			y = str2double(TABLE1.Function);

        elseif logical(strfind(y,'T'))
            ylbl = 'Time (absolute)';
            %y = TABLE1.Time;
			y = TABLE1.DateTime;

        elseif logical(strfind(y,'t'))
            ylbl = 'Time (relative)';
            %y = TABLE1.Time(:)-TABLE1.Time(2);
            %y = datenum(y)*100000;
			y = TABLE1.Time;

        end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot Stuff
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

        s = '-';
        cla; %clear axes
        plot_pvf(TABLE1,x,y,s,xlbl,ylbl);
        axislbls(1,:) = {xlbl,ylbl};
            
    end
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Internal Functionry
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function plot_pvf(TABLE1,x,y,s,xlbl,ylbl)
        
        axis = gca;
        
        plot( x, y), xlabel(xlbl), ylabel(ylbl);

        if Match(ylbl,'BW')
            
        elseif nMatch(ylbl,'Time')
			
			if size(y,2)>1
				MAXY = max(max(y));
			else
				MAXY = max(y);
			end
			if max(str2double(axis.YTickLabel))/MAXY < 1 
				axis.YTickLabel = num2str(str2double(axis.YTickLabel)*10^(floor(log(MAXY/max(str2double(axis.YTickLabel)))/2)));
			end

        elseif Match(ylbl,'Time') & Match(ylbl,'relative')
            %axis.YTickLabel = regexprep(axis.YTickLabel,'00:00:','');
            %axis.YTickLabel = [min(y):0.25:max(y)];
        end

        if Match(xlbl,'BW')
            %if max(str2double(axis.XTickLabel))/max(x) < 1 
            %    axis.XTickLabel = num2str(str2double(axis.XTickLabel)*10^(floor(log(max(x)/max(str2double(axis.XTickLabel)))/2)));
            %end

        elseif nMatch(xlbl,'Time')
			if size(y,2)>1
				MAXX = max(max(x));
			else
				MAXX = max(x);
			end
			
            if max(str2double(axis.XTickLabel))/MAXX < 1 
                axis.XTickLabel = num2str(str2double(axis.XTickLabel)*10^(floor(log(MAXX/max(str2double(axis.XTickLabel)))/2)));
			end
	
		elseif Match(xlbl,'Time') & Match(xlbl,'relative')
            %axis.XTickLabel = regexprep(axis.XTickLabel,'00:00:','');
            %axis.XTickLabel = [min(x):0.25:max(x)];
			%axis.XTickLabel = num2str(str2double(axis.XTickLabel)*10^(floor(log(max(x)/max(str2double(axis.XTickLabel)))/2)));
        end
        
        axis.XMinorGrid = 'on';
        axis.XMinorTick = 'on';
        axis.YMinorGrid = 'on';
        axis.YMinorTick = 'on';
        
    function nmatch=nMatch(string,mstring)
        nmatch = ~[logical(strfind(string,mstring)),logical(0)];
        nmatch = nmatch(1);
        
        
    function match=Match(string,mstring)
        match = [logical(strfind(string,mstring)),logical(0)];
        match = match(1);
  
		
		
		
		
function x = reAssign_X_axis(xlbl,TABLE1)
	
	if logical(strfind(xlbl,'Position (absolute)'))
		x = TABLE1.TS;
	
	elseif logical(strfind(xlbl,'Position (relative)'))
		x = cumsum(diff([TABLE1.TS(1,:);TABLE1.TS]));
		if TABLE1.TS(3)<TABLE1.TS(2)
			x = (-1) * x;
		end
			
	elseif logical(strfind(xlbl,'Time (absolute)'))
		xlbl = 'Time (absolute)';
		x = TABLE1.DateTime;
            
	elseif logical(strfind(xlbl,'BW'))
		x = (1:size(TABLE1,1)) - 1;
            
	elseif logical(strfind(xlbl,'Velocity'))
		x = TABLE1.Velocity;
            
	elseif logical(strfind(xlbl,'Time (relative)'))
		x = TABLE1.Time;
	end
	
	
	
function TABLE1 = shrink4BWs(TABLE1)
	TinT = size(TABLE1.TS(1,:),2);

	%Find the Time error between Table1 and the RADARs and
	% the Time error between The fireboxes and the RADARs
	% we could do Fireboxes to Breakwires, but that would
	% be dumb.
	% 1.) Seperate the Tables, and maybe even don't worry
	%		about anything other than Function,TS & Time
	
	for TinTcnt = 1:1:TinT;
		%TABLE1.Function(:,TinTcnt)
		TABLE = table(TABLE1.Function(:,TinTcnt),...
							TABLE1.TS(:,TinTcnt),...
						  TABLE1.Time(:,TinTcnt),...
					  TABLE1.Velocity(:,TinTcnt),...
					  TABLE1.DateTime(:,TinTcnt));
		TABLE.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity' 'DateTime'};
		NaNdex = find(isnan(TABLE.TS));
		TABLE(NaNdex,:) = [];
				
		TBLSTRUCT.TABLE{TinTcnt} = TABLE;
		
		FBWTBL = sum(cell2mat([strfind(TABLE.Function,'First Motion');strfind(TABLE.Function,'BW-')]))>0;
		FFBTBL = sum(cell2mat([strfind(TABLE.Function,'FB-MON');strfind(TABLE.Function,'STG-')]))>0;
		PUSHTBL = sum(cell2mat(strfind(TABLE.Function,'_PUSHER')))>0;

		if FBWTBL
			BWTBLInd = TinTcnt;
			TBLSTRUCT.TABLE{TinTcnt} = [];
			BWTBL = TABLE;
		elseif FFBTBL
			% Store these values for use in just a little bit.
			FBTBLInd = TinTcnt;
			FBTBL = TABLE;
		elseif PUSHTBL
			PUSHTBLInd = TinTcnt;
		end
	end
			
			
	for TinTcnt = 1:1:TinT
		if ~exist('FBTBLInd','var')
			FBTBLInd = 0;
		end
		if ~exist('PUSHTBLInd','var')
			PUSHTBLInd = 0;
		end
		if exist('BWTBLInd','var')
			if TinTcnt ~= BWTBLInd
				
				SomeTBL = TBLSTRUCT.TABLE{TinTcnt};
				if TinTcnt ~= FBTBLInd
				% Who's going inside this if statement?
				% It is not a Radar Table
				% and it won't be bigger than the Breakwire table
				% But we do want it in the TABLE1 variable,.....
				%	which should probably be renamed.
					[~,~,~,~,~,RDRBWTBL] = utils.math.FindError(BWTBL,SomeTBL);
					RDRBWTBL.Function = BWTBL.Function;
				else
				% Convert the Stage to Breakwire Number.  Unless it's
				% function is FB-MON, it won't be an integer
				% Here we don't care about what stage it is, but actually
				% what breakwire it would be (i.e: BW-1.2, BW-5.8, BW-7.3 etc...)
				
				% So, at this point, we have:  
				% BWTBL in existence
				% FBTBLInd == TinTcnt => FBTBL exists too
					FBTBL_wv = FBTBL;
					BWTBL_wv = BWTBL;
					FBADDTBL = BWTBL;
					REMFFBADDTBL = size(FBTBL,1);
					FBADDTBL(1:REMFFBADDTBL,:) = [];
					FBADDTBL.Function(:) = cellstr('');
					FBADDTBL.TS(:) = NaN;
					FBADDTBL.Time(:) = NaN;
					FBADDTBL.Velocity(:) = NaN;
					FBADDTBL.DateTime(:) = FBTBL.DateTime(size(FBTBL,1));
					FBTBL_wv = [FBTBL_wv;FBADDTBL];
					EinFBTBL = size(FBTBL,1);
					
					if EinFBTBL > 0
						for i=1:EinFBTBL
							if i > 1
								clear BWLS BWHS BWAddTo STG STG_BW;
								ii = 1;
								while ~(BWTBL.TS(ii) < FBTBL.TS(i) && FBTBL.TS(i) < BWTBL.TS(ii+1)) && ...
										~(BWTBL.TS(ii) > FBTBL.TS(i) && FBTBL.TS(i) > BWTBL.TS(ii+1));
									ii = ii + 1;
								end
								BWLS = BWTBL.TS(ii);
								BWHS = BWTBL.TS(ii+1);
								BWAddTo = str2double(regexprep(regexprep(BWTBL.Function(ii),'BW-',''),'First Motion','0'));
								STG = FBTBL.TS(i);
								STG_BW = ((STG - BWLS)/(BWHS - BWLS)) + BWAddTo;
								FBTBL_wv.Function(i) = cellstr(num2str(STG_BW));
							elseif i == 1
								FBTBL_wv.Function(i) = regexprep(FBTBL_wv.Function(i),'FB-MON','0.0000000');
								FBTBL_wv.TS(1) = BWTBL_wv.TS(1);
							end
						end
						RDRBWTBL = FBTBL_wv;
					end
				
				
				end
				
				if size(TABLE1,1) > size(BWTBL,1)
					TABLE1(size(BWTBL,1)+1:size(TABLE1,1),:) = [];
				end
				TABLE1.Function(:,TinTcnt) = RDRBWTBL.Function;
				TABLE1.Time(:,TinTcnt) = RDRBWTBL.Time;
				TABLE1.TS(:,TinTcnt) = RDRBWTBL.TS;
				TABLE1.Velocity(:,TinTcnt) = RDRBWTBL.Velocity;
				TABLE1.DateTime(:,TinTcnt) = RDRBWTBL.DateTime;
				TABLE1.Function = regexprep(regexprep(TABLE1.Function,'First Motion','0.0000000'),'BW-','');
				TABLE1 = fstripPUSHERTbls(TABLE1,PUSHTBLInd);
			else
				TABLE1.Function = regexprep(regexprep(TABLE1.Function,'First Motion','0.0000000'),'BW-','');
			end
			
		end
	end
	
   
	
	
function TABLE1 = fstripPUSHERTbls(TABLE1,PUSHTBLInd)
	if PUSHTBLInd > 0
		TABLE1.Function(:,PUSHTBLInd) = cellstr('NaN');
		TABLE1.Time(:,PUSHTBLInd) = NaN;
		TABLE1.TS(:,PUSHTBLInd) = NaN;
		TABLE1.Velocity(:,PUSHTBLInd) = NaN;
		TABLE1.DateTime(:,PUSHTBLInd) = TABLE1.DateTime(size(TABLE1.Time,1),PUSHTBLInd);
	end
	%TABLE1.DateTime(:,PUSHTBLInd) = ;
