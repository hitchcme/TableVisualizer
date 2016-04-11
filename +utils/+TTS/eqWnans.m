function	TBLout = eqWnans(TBLin)
% equalize table sizes to plot a single variable as multiple plots
	TBL = TBLin;
	
	for i=1:size(TBL,2)
		if exist('TBLsiz','var')
			TBLsiz = [TBLsiz;size(TBL{i},1)];
		else
			TBLsiz = size(TBL{i},1);
		end
	end

	MAXSiz = max(TBLsiz);
	MINSiz = min(TBLsiz);

	
	for i=1:size(TBLsiz,1)
		TBLsiz(i);
		cid = TBLsiz(i) + 1;
		FUNCStr = TBL{i}.Function(1);
		TS = TBL{i}.TS;
		FUNC = TBL{i}.Function;
		TIM = TBL{i}.Time;
		DTIM = TBL{i}.DateTime;
		DTIML = TBL{i}.DateTime(TBLsiz(i));
		VEL = TBL{i}.Velocity;
		TS(cid:1:MAXSiz) = NaN;
		FUNC(cid:1:MAXSiz) = FUNCStr;
		TIM(cid:1:MAXSiz) = NaN;
		VEL(cid:1:MAXSiz) = NaN;
		
		DTIM(cid:1:MAXSiz) = DTIML;
		if TBLsiz(i) == 1
			FUNC = transpose(FUNC);
			TS = transpose(TS);
			TIM = transpose(TIM);
			VEL = transpose(VEL);
			DTIM = transpose(DTIM);
		end
		TBL{i} = table(FUNC,TS,TIM,VEL,DTIM);
		TBL{i}.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity' 'DateTime'};
		
	end
	
	clear TS VEL TIM FUNC DTIM
	
	for i=1:1:size(TBLsiz,1)
		if exist('TS','var')
			FUNC = [FUNC,TBL{i}.Function];
			
			TS = [TS,TBL{i}.TS];
			TIM = [TIM,TBL{i}.Time];
			VEL = [VEL,TBL{i}.Velocity];
			DTIM = [DTIM,TBL{i}.DateTime];
		else
			FUNC = TBL{i}.Function;
			TS = TBL{i}.TS;
			TIM = TBL{i}.Time;
			VEL = TBL{i}.Velocity;
			DTIM = TBL{i}.DateTime;
		end
	end
	TBL = table(FUNC,TS,TIM,VEL,DTIM);
	TBL.Properties.VariableNames = {'Function' 'TS' 'Time' 'Velocity' 'DateTime'};
	TBL.Time(1,:);
	TBLout = TBL;
	
	%plot(RTBL{1:size(RTBL,2)}.Time,RTBL{1:size(RTBL,2)}.TS)
	
	