function mapStructure(STRUCT,SName)

	FN = fieldnames(STRUCT);
	
	for i = 1:size(FN,1)
		VAR = STRUCT.(char(FN(i)));
		sum([ischar(VAR),iscell(VAR),isstruct(VAR)]);
		if ischar(VAR)
			STP = horzcat(SName,'.',char(FN(i)),'\n');
			fprintf(STP)
			fprintf('\t%s \n',STRUCT.(char(FN(i))))
			%fprintf(STRUCT.(char(FN(i))))
		elseif iscell(VAR)
			STP = horzcat(SName,'.',char(FN(i)));
			fprintf('%s\n',STP)
			for i1 = 1:size(STRUCT.(char(FN(i))))
				if isstruct(STRUCT.(char(FN(i))){1})
					STRUCT1 = STRUCT.(char(FN(i))){i1};
					STP1 = horzcat(STP,'{',num2str(i1),'}');
					utils.misc.mapStructure(STRUCT1,STP1);
				end
			end
		elseif isstruct(VAR)
			STP = horzcat(SName,'.',char(FN(i)));
			fprintf('%s\n',STP)
			STRUCT1 = STRUCT.(char(FN(i)));
			utils.misc.mapStructure(STRUCT1,STP)
		elseif istable(VAR)
			STP = horzcat(SName,'.',char(FN(i)));
			fprintf('%s\n',STP)
			TFN = regexprep(fieldnames(VAR),'Properties','');
			for i2=1:size(TFN,1)
				fprintf('\t%s',char(TFN(i2)))
			end
			fprintf('\n')
		end
		%fprintf('\n')
		%utils.misc.mapStructure(STRUCT.(char(FN(i))),VAR1(1))
	end