function NewTBLEntry = fixVel(TBLEntry, TABLE)

	%datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss.SSSSSS');

	for i=size(TBLEntry.Time,1):(-1):1
			ii = size(TABLE,1);
			%DIRECTION = (TABLE.TS(3)-TABLE.TS(2))/abs(TABLE.TS(3)-TABLE.TS(2));
			
			% New Direction Figuring (fixes problems when there are bad
			% trackstations like a Launch Point TS of 1000000
			DIRECTION = round(sum(diff(TABLE.TS) ./ abs(diff(TABLE.TS)))/size(diff(TABLE.TS),1));
			if DIRECTION >= 1
			
				while TBLEntry.TS(i,:) <= TABLE.TS(ii,:)
					ii = ii - 1;
				end
			else
				while TBLENtry.TS(i,:) >= TABLE.TS(ii,:)
					ii = ii - 1;
				end
			end
		
			dy = TBLEntry.TS(i)-TABLE.TS(ii);
			dt = datenum(TBLEntry.Time(i)-TABLE.Time(ii))*86400;
		
			TBLEntry.Velocity(i) = round(dy/dt,2);
		end

	NewTBLEntry = TBLEntry;
	