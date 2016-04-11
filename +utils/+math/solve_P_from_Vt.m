function TABLEout = solve_P_from_Vt(TABLEin)
% Solve for Position from V(t)
% There should already be a prefilled data point for T0, and here we're
% assuming so.



	TABLE = TABLEin;
	TABLE(1,:) = [];
	
	if isdatetime(TABLE.Time)
		t = datenum(TABLE.Time) * 86400;
	else
		t = TABLE.Time;
	end
	dt = sum(diff(t(1:50)))/50;
	
	v = TABLE.Velocity;
	dv = diff(v(1:5:100))/5;
	ddv = diff(dv);
	dddv = diff(ddv);
	ddddv = diff(dddv);

	dv = sum(dv(1:3)) / size(dv(1:3),1);
	ddv = transpose(sum(ddv(1:3)) / size(ddv(1:3),1));
	dddv(1:100) = -sum(dddv(1:3))/size(dddv(1:3),1);
	ddv(1:100) = -ddv;
	ddv = transpose(ddv);
	dv(1:100) = -dv;
	dv = transpose(dv);
	vx = v(1) + cumsum(dv) + cumsum(ddv) + cumsum(dddv);
	tx(1:100) = -dt;
	tx = cumsum(transpose(tx)) + t(1);
	vx = flipud(vx);
	tx = flipud(tx);
	
	
	t_offset = max(tx) - min(t);
	tx = tx - t_offset;
	
	
	if isdatetime(TABLE.Time)
		tx = datetime(tx/86400,'ConvertFrom','Datenum');
	end

	TABLE_wv(1:size(vx,1)) = TABLE.Function(1);
	TABLE_wv = cell2table(transpose(TABLE_wv));
	TABLE_wv.Properties.VariableNames = {'Function'};
	TABLE_wv.Time = tx;
	TABLE_wv.Velocity = vx;
	TABLE_wv(size(TABLE_wv,1),:) = [];
	
	while sum(TABLE_wv.Velocity < 0) > 1
		TABLE_wv(1,:) = [];
	end
	
	v0 = TABLE_wv.Velocity(1);
	v1 = TABLE_wv.Velocity(2);
	dv = v1 - v0;
	t0 = datenum(TABLE_wv.Time(1)) * 86400;
	t1 = datenum(TABLE_wv.Time(2)) * 86400;
	dt = t1 - t0;
	m = dv/dt;
	% y = mx + b
	b = v0 - ( m * t0 );
	tx = (-b) / m;
	tx = datetime((tx)/86400,'ConvertFrom','Datenum');
	TABLE_wv.Time(1) = tx;
	TABLE_wv.Velocity(1) = 0;

	TABLE = [TABLE_wv;TABLE];

	






	%TABLE = TABLEin;

	%TABLE = utils.math.lowside_fill(TABLE);
	if isdatetime(TABLE.Time)
		T = datenum(TABLE.Time) * 86400;
	else
		T = TABLE.Time;
	end
	
	
	%T = utils.nav.ZeroTinSec(TABLE.Time);
	V = TABLE.Velocity;
	dt = [0;diff(T)];
	TABLE.TS = TABLE.Velocity .* dt;
	TABLE.TS = cumsum(TABLE.TS);
	TABLE = [TABLE(:,1) TABLE(:,4) TABLE(:,2) TABLE(:,3)];
	
	
	TABLEout = TABLE;
	
	
	
