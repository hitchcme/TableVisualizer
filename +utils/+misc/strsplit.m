function ARRAY = strsplit(STRING,DELIM)
% This one seems faster than the original
    if ~exist('DELIM','var')
        DELIM = ' ';
    end
    TDELIM = horzcat(DELIM,DELIM,DELIM);
    DDELIM = horzcat(DELIM,DELIM);
    
    STRING = regexprep(STRING,TDELIM,DELIM);
    STRING = regexprep(STRING,DDELIM,DELIM);
    STRING = regexprep(STRING,TDELIM,DELIM);
    STRING = regexprep(STRING,DDELIM,DELIM);
    STRING = regexprep(STRING,TDELIM,DELIM);
    STRING = regexprep(STRING,DDELIM,DELIM);
    

    ARRAY = transpose(cellstr(strread(STRING,'%s','delimiter',DELIM)));