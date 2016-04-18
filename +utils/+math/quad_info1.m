function pinfo = quad_info1(tbtw0s,b,yoffs)
    
    Dbtw0s = ((b * tbtw0s^2)/6) + (yoffs*tbtw0s);
    a = -b/tbtw0s;
    
    x_ext = -b/(2 * a);
    x = x_ext;
    
    y_ext = a * x^2 + b * x + yoffs;
    
    pinfo={a, b, x_ext, y_ext, tbtw0s, Dbtw0s};