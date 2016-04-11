function pinfo = quad_info0(tbtw0s,Dbtw0s,yoffs)
    b = 6*(Dbtw0s-yoffs*tbtw0s)/(tbtw0s^2);
    a = -b/tbtw0s;
    % y(x) = ax^2 + bx + c
    % y'(x) = 2ax + b
    %   0 = 2ax + b
    %   0 - b = 2ax
    %   -b/(2a)
    % you tell me what c is, this is for a and b!!!!
    x_ext = -b/(2 * a);
    x = x_ext;
    
    y_ext = a * x^2 + b * x + yoffs;
    
    pinfo={a, b, x_ext, y_ext, tbtw0s, Dbtw0s};