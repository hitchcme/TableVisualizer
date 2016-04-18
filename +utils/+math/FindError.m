function [ERR,avgterr,SD,MIN,MAX,RDRBWTBL] = FindError(BWTBL,RDRTBL)
	
	% When should BreakWire Fire?
	
	% Calculate First Motion Error
	FMERR = BWTBL.Time(1) - RDRTBL.Time(1);

	BWTBLkul = BWTBL(1,:);
	RDRTBLkul = RDRTBL(1,:);

	%Removal of the First Motions happens in the 'When Should BW fire'
	%	routine, so these next two lines are commented out, with this text
	%	to remind me or whomever.
	%BWTBL(1,:) = [];
	%RDRTBL(1,:) = [];
	
	[ERR,avgterr,SD,MIN,MAX,RDRBWTBL] = WhShBW_Fire(BWTBL,RDRTBL);
	
	RDRBWTBL = [RDRTBLkul;RDRBWTBL];






function [ERR,avgterr,SD,MIN,MAX,RDRBWTBL] = WhShBW_Fire(TBL1,RDRTBL)
% Where in time should BW fire?
%	Linear interpolation? (Table should be sorted by Position)

	TBL = [TBL1;RDRTBL];
	TBL = sortrows(TBL,2);

	% Remove First Motion and The first Radar entry
	TBL(1:2,:) = [];
	TBL = sortrows([RDRTBL;TBL1],2);


	bwls = regexprep(regexprep(TBL.Function,'-[0-9][0-9]',''),'-[0-9]','');
	% Get BW line indexes
	idx = find(ismember(bwls,'BW'));
	BWTBL = TBL(idx,:);
	%'High Side'
	if size(TBL,1) > idx(size(idx,1))
		RDRTBLhs = TBL(idx+1,:);
	else
		RDRTBLhs = TBL(idx-2,:);
	end
	%'Low Side'
	RDRTBLls = TBL(idx-1,:);
	
	dt = RDRTBLhs.Time - RDRTBLls.Time;
	dy = RDRTBLhs.TS - RDRTBLls.TS;
	dv = RDRTBLhs.Velocity - RDRTBLls.Velocity;

	m = dy ./ dt;
	m2 = dv ./ dt;
	
	b = RDRTBLls.TS - (m .* RDRTBLls.Time);
	b2 = RDRTBLls.Velocity - (m2 .* RDRTBLls.Time);
	
	t = (BWTBL.TS - b) ./ m;
	v2 = (m2 .* t) + b2;
	
	avgterr = sum(BWTBL.Time - t)/size(t,1);
	ERR = BWTBL.Time - t;
	RDRBWTBL = BWTBL;
	RDRBWTBL.Time = t;
	RDRBWTBL.Velocity = v2;
	RDRBWTBL.Function(1:size(RDRBWTBL.Function)) = RDRTBL.Function(1);
	%DTERR = num2str(floor(round(t,6)*1000000)/1000000,6)
	%DTERR = 
	RDRBWTBL.DateTime = datetime(BWTBL.DateTime - (round(ERR,6)/24/60/60));
	SD = std(BWTBL.Time - t);
	MIN = min(BWTBL.Time - t);
	MAX = max(BWTBL.Time - t);





