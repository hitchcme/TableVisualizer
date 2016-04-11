function logit(OPTION,WHERE,ENTRY,UseFor,UseDate)

	if nargin < 4 || ~isnumeric(OPTION)
		fprintf('Use:\n');
		fprintf('\tlogit(Option,Where,Entry)\n');
		fprintf('\t\tOption: (integer)\n');
		fprintf('\t\t\t1 = Create New Log File\n');
		fprintf('\t\t\t2 = Append to Log File\n');
		fprintf('\t\tWhere: $PATH to Log File (string)\n');
		fprintf('\t\tEntry: the Log Entry (string)\n');
	else
		if OPTION == 1
			OPTION = 'w';
		elseif OPTION == 2
			OPTION = 'a';
			if ~exist(WHERE,'file')
				OPTION = 'w';
			end
		end
		
		fid = fopen(WHERE,OPTION);
		
		if UseDate
			ENTRY = horzcat(datestr(datetime),'\t',ENTRY);	
			ENTRY = regexprep(ENTRY,'\\n','\n\t\t');
			ENTRY = horzcat(ENTRY,'\n\n');
		else
			ENTRY = horzcat(ENTRY,'\n');
        end
		
        if ispc
            ENTRY = regexprep(ENTRY,'\\t','\t');
            ENTRY = regexprep(ENTRY,'\\n','\n');
        end
        
		if UseFor
			for i=1:1:size(ENTRY,2)
                if ~ispc
                    fprintf(fid,char(ENTRY(i)));
                else
                    fprintf(fid,'%s',char(ENTRY(i)));
                end
			end
        else
            if ~ispc
                fprintf(fid,ENTRY);
            else
                fprintf(fid,'%s',ENTRY);
            end
            
		end
		
		fclose(fid);
		
	end