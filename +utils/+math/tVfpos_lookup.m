function tim_vel = tVfpos_lookup(tbl,position)

    t0 = 1;
    tbl.Properties.VariableNames = {'Time' 'Position' 'Velocity'};
    
    while tbl.Position(t0) < position && t0 < size(tbl,1)
        t0 = t0+1;
    end
    t1 = t0;
    t0 = t0 - 1;
    
    %        y = m x + b
    %       y0 = m x0 + b
    %       y0 - (m x0) = b
    %       b = y0 - (m x0)
    y1 = tbl.Position(t1);
    x1 = tbl.Time(t1);
    
    y0 = tbl.Position(t0);
    x0 = tbl.Time(t0);

    m = (y1 - y0) / (x1 - x0);
    b = y0 - ( m * x0 );

    tim = (position - b) / m;

    y1 = tbl.Velocity(t1);
    y0 = tbl.Velocity(t0);
    
    m = (y1 - y0) / (x1 - x0);
    b = y0 - ( m * x0 );
    
    vel = m * tim + b;
    
    tim_vel_wv = cell2table({tim,vel});
    tim_vel_wv.Properties.VariableNames = {'Time' 'Velocity'};
    tim_vel = tim_vel_wv;