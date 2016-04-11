function TABLES = enumRADARs(TABLES)

	%Just some testing here to try and cause errors
	%TABLES.RDR9 = TABLES.RADAR{1}
	%TABLES = rmfield(TABLES,'RDR1')
	%TABLES = rmfield(TABLES,'RDR2')
	%end of testing

	%Move RADAR.fields back to original state in TABLES.RDR#.
	if sum(ismember(fieldnames(TABLES),'RADAR'))
		imax = size(TABLES.RADAR,1);
		for i=1:1:imax
			STR = strcat('RDR',num2str(i));
			RNmatch_i = sum(ismember(fieldnames(TABLES),STR));
			if RNmatch_i
				Imatch_i = sum(ismember(fieldnames(TABLES.(STR)),'IMPACT'));
				Pmatch_i = sum(ismember(fieldnames(TABLES.(STR)),'PUSHER'));
			else
				Imatch_i = 0;
				Pmatch_i = 0;
			end
			
			if ~isempty(TABLES.RADAR{i})
				Imatch_o = sum(ismember(fieldnames(TABLES.RADAR{i}),'IMPACT'));
				Pmatch_o = sum(ismember(fieldnames(TABLES.RADAR{i}),'PUSHER'));
			else
				Imatch_o = 0;
				Pmatch_o = 0;
			end
			
			%RDR# overrides RADAR{#}, because it is the most recent import
			if ~Imatch_i && Imatch_o
				TABLES.(STR).IMPACT = TABLES.RADAR{i}.IMPACT;
				TABLES.(STR).POS = TABLES.RADAR{i}.POS;
			end
			
			if ~Pmatch_i && Pmatch_o
				TABLES.(STR).PUSHER = TABLES.RADAR{i}.PUSHER;
				TABLES.(STR).POS = TABLES.RADAR{i}.POS;
			end
			
		end
	end
	
	RADARs = regexprep(regexprep(regexprep(regexprep(regexprep(fieldnames(TABLES),'MPATH',''),'MID',''),'TABLE1',''),'RDR',''),'RADAR','');
	RADARs = str2double(cellstr(cell2mat(RADARs)));
	
	
	if ~isnan(RADARs)
		for i = 1:max(RADARs)
			if ismember(i,RADARs)
				STR = char(strcat('RDR',num2str(i)));
				RADAR{i} = TABLES.(STR);
				TABLES = rmfield(TABLES,STR);
			else
				%RADAR{i} = [];
			end
		end
		TABLES.RADAR = transpose(RADAR);
	end
	
