function avg = RAvg(x,samples)

    avg = double(x(1:size(x,1)-1) + (x(2:size(x,1)) - x(1:size(x,1)-1))/samples);
    avg = [x(1);avg];