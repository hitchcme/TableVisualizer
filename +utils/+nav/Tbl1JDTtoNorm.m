function tim_arr = Tbl1JDTtoNorm(ColSepTimStr)

    %datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss.SSSSSS')
    ColSepTimStr = strsplit1(ColSepTimStr,':');
    
    JDStr = str2double(strcat(ColSepTimStr(1),ColSepTimStr(2)));
    
    ColSepTimStr = str2double(ColSepTimStr);

    Year = ColSepTimStr(1);
    Hour = ColSepTimStr(3);
    Min = ColSepTimStr(4);
    Sec = ColSepTimStr(5);
    mS = ColSepTimStr(6)/1000;
    
    dat_arr = utils.nav.jl2normaldate(JDStr);
    dat_arr = strsplit1(regexprep(dat_arr,'-',' '));
    dat_arr(4) = [];
	month = ['Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'];
	month = str2double({num2str(0.75+strfind(month,dat_arr(2))/4)});
	day = str2double(dat_arr(1));
    clear dat_arr;

    tim_arr = datetime(Year,month,day,Hour,Min,Sec,mS);
    
    
    
    
function ARRAY = strsplit1(STRING,DELIM)
% speeds the whole process by about 20 mS
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
    
    
    