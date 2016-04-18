function [ERR,CMT] = FindTError(TBL1,TBL2)

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

	idx1 = abs(BWTBL.Time - RDRTBLls.Time) < abs(BWTBL.Time - RDRTBLhs.Time);
	idx2 = abs(BWTBL.Time - RDRTBLhs.Time) < abs(BWTBL.Time - RDRTBLls.Time);
	
	idx1 = find(idx1);
	RDRTBLcls = RDRTBLls(idx1,:);

	idx2 = find(idx2);
	RDRTBLchs = RDRTBLhs(idx2,:);

	RDRTBL = [RDRTBLchs;RDRTBLcls];
	RDRTBL = sortrows(RDRTBL,3);
	CMT = sortrows([RDRTBL;BWTBL],3);
	
	ERR = [BWTBL.Time - RDRTBL.Time,BWTBL.TS - RDRTBL.TS];
	
	
	
	
	
	
	
	