function RNfRDR(NNum,Num,TBLPTH)
	
	load(TBLPTH,'TABLES');
	I = sum(ismember(fieldnames(TABLES.RADAR{Num}),'IMPACT'));
	P = sum(ismember(fieldnames(TABLES.RADAR{Num}),'PUSHER'));
	
	TABLES.RADAR{NNum} = TABLES.RADAR{Num};
	
	if I
		
		TBLIMP = TABLES.RADAR{NNum}.IMPACT;
		TSiz = size(TBLIMP.Velocity,1);
		TBLIMP.Function = regexprep(TBLIMP.Function,num2str(Num),num2str(NNum));
		
		TBLIMP.Velocity(2:TSiz) = TBLIMP.Velocity(2:TSiz) + (rand(TSiz-1,1) - 0.5)*rand/10;
		TBLIMP.TS(2:TSiz) = TBLIMP.TS(2:TSiz) + (rand(TSiz-1,1) - 0.5)*rand/10;
		
		RT = (rand(TSiz,1) - 0.5)/100
		RDT = RT / 86400
		TBLIMP.Time = TBLIMP.Time + RT;
		TBLIMP.DateTime = TBLIMP.DateTime + RDT;
	end
	if P
		TBLPUS = TABLES.RADAR{NNum}.PUSHER;
		TSiz = size(TBLPUS.Velocity,1);
		TBLPUS.Function = regexprep(TBLPUS.Function,num2str(Num),num2str(NNum));
		
		TBLPUS.Velocity(2:TSiz) = TBLPUS.Velocity(2:TSiz) + (rand(TSiz-1,1) - 0.5)*rand/10;
		TBLPUS.TS(2:TSiz) = TBLPUS.TS(2:TSiz) + (rand(TSiz-1,1) - 0.5)*rand/10;
		
		RT = (rand(TSiz,1) - 0.5)/100
		RDT = RT / 86400
		TBLPUS.Time = TBLPUS.Time + RT;
		TBLPUS.DateTime = TBLPUS.DateTime + RDT;
	end
	
	if exist('TBLIMP','var')
		'There is an Impact file';
		TABLES.RADAR{NNum}.IMPACT = TBLIMP;
	end
	
	if exist('TBLPUS','var')
		'Thre is a Pusher file';
		TABLES.RADAR{NNum}.PUSHER = TBLPUS;
	end
	
	TABLES.RADAR{NNum};
	
	save(TBLPTH,'TABLES');