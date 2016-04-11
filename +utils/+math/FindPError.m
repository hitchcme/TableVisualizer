function [ERR,CMT] = FindPError(TBL1,TBL2)

	%BWs
	T1 = TBL1.Time;
	%RADAR
	T2 = TBL2.Time;
	

	TBL = [TBL1;TBL2];
	TBL = sortrows(TBL,2);
	% Remove First Motion and The first Radar entry
	TBL(1:2,:) = [];
	
	bwls = regexprep(regexprep(TBL.Function,'-[0-9][0-9]',''),'-[0-9]','');
	% Get BW line indexes
	idx = find(ismember(bwls,'BW'));
	
	BWTBL = TBL(idx,:);
	
	%'High Side'
	RDRTBLhs = TBL(idx+1,:);
	
	%'Low Side'
	RDRTBLls = TBL(idx-1,:);

	idx1 = abs(BWTBL.TS - RDRTBLls.TS) < abs(BWTBL.TS - RDRTBLhs.TS);
	idx2 = abs(BWTBL.TS - RDRTBLhs.TS) < abs(BWTBL.TS - RDRTBLls.TS);
	
	idx1 = find(idx1);
	RDRTBLcls = RDRTBLls(idx1,:);

	idx2 = find(idx2);
	RDRTBLchs = RDRTBLhs(idx2,:);

	RDRTBL = [RDRTBLchs;RDRTBLcls];
	%RDRTBL = sortrows(RDRTBL,2);
	CMT = sortrows([RDRTBL;BWTBL],3);
	CMT = [TBL1(1,:);TBL2(1,:);CMT];
	
	ERR = [BWTBL.Time - RDRTBL.Time,BWTBL.TS - RDRTBL.TS];
	
	
	
	
	
	
	
	