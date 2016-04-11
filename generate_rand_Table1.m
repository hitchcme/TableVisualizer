function TABLE1 = generate_rand_Table1(wholepathfilename)

datetime.setDefaultFormats('default','yyyy-MM-dd HH:mm:ss.SSSSSS');


%  No Input Detected, open the user interface
if nargin == 0
    [FileName,PathName,FilterIndex] = uiputfile('./*.*');
    wholepathfilename = strcat(PathName,FileName);
else
    wholepathfilename = GetFullPath(wholepathfilename);
end


if exist(wholepathfilename, 'file') == 2
delete(wholepathfilename);
end


if rand > 0.5
MissionType = 'E';
else
MissionType = 'I';
end
MissionIDPrefix = 0;
while MissionIDPrefix > 90 || MissionIDPrefix < 40
MissionIDPrefix = round(rand*100);
MissionIDPrefix_str = num2str(MissionIDPrefix);
end
MissionNum = 0;
while MissionNum < 65 || MissionNum > 90
MissionNum = char(round(rand*100));
end
MissionNum1 = 0;
while MissionNum1 < 1 || MissionNum > 100
MissionNum1 = round(rand*100);
MissionNum1_str = num2str(MissionNum1);
end

Mission = strcat(MissionIDPrefix_str,MissionType,'-',MissionNum,MissionNum1_str);

year = strsplit(regexprep(date,'-',' '));
year = str2double(year(3));
if ~(rem(year,4)>0)
maxday = 366;
else
maxday = 365;
end
day = 0;
while day > maxday || day < 1
day = round((rand*366));
if day < 10
day_str = strcat('00',num2str(day));
elseif day < 100
day_str = strcat('0',num2str(day));
else
day_str = num2str(day);
end
end
hr = -1;
while hr < 0 || hr >= 24
hr = round(rand*24);
if hr < 10
hr_str = strcat('0',num2str(hr));
else
hr_str = num2str(hr);
end
end
min = -1;
while min < 0 || min >= 60
min = round(rand*59);
if min < 10
min_str = strcat('0',num2str(min));
else
min_str = num2str(min);
end
end

sec = -1;
while sec < 0 || sec >= 60
sec = round(rand*59);
if sec < 10
sec_str = strcat('0',num2str(sec));
else
sec_str = num2str(sec);
end
end
uS = round(rand*999999);
uS_str = num2str(uS);

FirstMotionTime_str = strcat(day_str,':',hr_str,':',min_str,':',sec_str,':',uS_str,'\n');

if rand > 0.5
LaunchPoint = round(double(26400+(rand*4000)));
else
LaunchPoint = round(double(26400-(rand*4000)));
end

LaunchPoint_str = strcat(num2str(LaunchPoint),'\n');

if MissionType == 'I'
Direction = 'NORTH';
Trav_pol = 1;
elseif MissionType == 'E'
Direction = 'SOUTH';
Trav_pol = -1;
end
TABLE1 = [];
while size(TABLE1,1) < 9
%%%%%%%%%% Breakwires %%%%%%%%%%
%Random number of breakwires, between 5 and 20
MAXBW = 0;
while MAXBW < 9 || MAXBW > 20
MAXBW = round((rand * 15) + 5);
end

BWTS = LaunchPoint;
maxtt = 0;
b = 0;
yoffs = 0;
while (maxtt < 15 || maxtt > 20)
    maxtt = rand * 100;
end

while b < 150 || b > 400
    b = rand()*1000;
end

while yoffs > -20 || yoffs < -40
    yoffs = rand()*(-30);
end

fterms = quad_info1(maxtt,b,yoffs);
a = cell2mat(fterms(1));
b = cell2mat(fterms(2));
c = yoffs;

t = 0;
tPV = {t, (a*t^3)/3+(b*t^2)/2+c*t, (a*t^2)+b*t+c};
it = 0;
while t < maxtt
    it = it+1;
    tPV(it,:) = {t, (a*t^3)/3+(b*t^2)/2+c*t, (a*t^2)+b*t+c};
    t = t + 0.001;
end
tPV = cell2table(tPV);
tPV.Properties.VariableNames = {'Time' 'Position' 'Velocity'};

%tVfpos_lookup(tPV,1004)
no_more = false;
for i=1:1:MAXBW

    if Trav_pol < 0
        BWTS = BWTS - round(rand()*(LaunchPoint/MAXBW)+100);
    else
        BWTS = BWTS + round(rand()*((52800 - LaunchPoint)/MAXBW)+100);
    end
    TABLE1{i,1}=strcat('BW-',num2str(i));
    TABLE1{i,2} = num2str(BWTS);

end
TBL1Siz = size(TABLE1);
while str2double(TABLE1(TBL1Siz(1),2)) < 100 || str2double(TABLE1(TBL1Siz(1),2)) > 52800
TBL1Siz = size(TABLE1);
TABLE1(TBL1Siz(1),:) = [];
TBL1Siz = size(TABLE1);
end

MAXVel_TrvlD = 0;
while MAXVel_TrvlD < 13200 - 13200 * 25/100 || MAXVel_TrvlD > 13200 + 13200 * 25/100
if Trav_pol < 0
MAXVel_TrvlD = rand()*(LaunchPoint/2);
MAXVel_TS = LaunchPoint - MAXVel_TrvlD;
else
MAXVel_TrvlD = rand()*((52800-LaunchPoint)/2);
MAXVel_TS = LaunchPoint + MAXVel_TrvlD;
end
end



for x = 1:1:size(TABLE1,1)

TS = str2double(TABLE1(x,2));
position = abs( TS - LaunchPoint );

TimVel = tVfpos_lookup(tPV,position);
reltim = double(TimVel.Time);
velocity = double(TimVel.Velocity);

if reltim <= 0
    reltim = 0;
end

Timestamp = regexprep(FirstMotionTime_str,':',' ');
Timestamp = regexprep(Timestamp,'\\n','');
Timestamp = strsplit(Timestamp);
Timestamp = str2double(Timestamp);
Timestamp(4) = floor(Timestamp(4) + reltim);
Timestamp(5) = round((10^6)*(Timestamp(4) + reltim - floor(Timestamp(4) + reltim)) + Timestamp(5));
while Timestamp(5) >= 10^6
Timestamp(4) = Timestamp(4) + 1;
Timestamp(5) = round(Timestamp(5) - 10^6);
end
while Timestamp(4) >= 60
Timestamp(3) = Timestamp(3) + 1;
Timestamp(4) = Timestamp(4) - 60;
end
while Timestamp(3) >= 60
Timestamp(2) = Timestamp(2) + 1;
Timestamp(3) = Timestamp(3) - 60;
end
while Timestamp(2) >= 24
Timestamp(1) = Timestamp(1) + 1;
Timestamp(2) = Timestamp(2) - 24;
end
while Timestamp(1) >= maxday
Timestamp(1) = Timestamp(1) - maxday;
end
Timestamp = strsplit(num2str(Timestamp));

if str2double(Timestamp(1)) < 10
Timestamp(1) = strcat('00',Timestamp(1));
elseif str2double(Timestamp(1)) < 100
Timestamp(1) = strcat('0', Timestamp(1));
end

if str2double(Timestamp(2)) < 10
Timestamp(2) = strcat('0',Timestamp(2));
end
if str2double(Timestamp(3)) < 10
Timestamp(3) = strcat('0',Timestamp(3));
end
if str2double(Timestamp(4)) < 10
Timestamp(4) = strcat('0',Timestamp(4));
end
if str2double(Timestamp(5)) < 10
Timestamp(5) = strcat('00000',Timestamp(5));
elseif str2double(Timestamp(5)) < 100
Timestamp(5) = strcat('0000',Timestamp(5));
elseif str2double(Timestamp(5)) < 1000
Timestamp(5) = strcat('000',Timestamp(5));
elseif str2double(Timestamp(5)) < 10000
Timestamp(5) = strcat('00',Timestamp(5));
elseif str2double(Timestamp(5)) < 100000
Timestamp(5) = strcat('0',Timestamp(5));
end
Timestamp = strcat(Timestamp(1),':',Timestamp(2),':',Timestamp(3),':',Timestamp(4),':',Timestamp(5));
TABLE1(x,3) = Timestamp;

Time1 = Tbl1JDTtoNorm(char(strcat(num2str(year),':',Timestamp)));
Time0 = Tbl1JDTtoNorm(char(regexprep(strcat(num2str(year),':',FirstMotionTime_str),'\\n','')));
GT = datestr(Time1 - Time0,'HH:MM:SS:FFF');
TABLE1(x,4) = {GT};
TABLE1(x,5) = {num2str(velocity)};

end

while str2double(regexprep(TABLE1(size(TABLE1,1),4),':','')) <= str2double(regexprep(TABLE1((size(TABLE1,1)-1),4),':',''))
    TABLE1(size(TABLE1,1),:) = [];
    MAXBW = MAXBW - 1;
end


end

fid = fopen(wholepathfilename,'w');
fprintf(fid,strcat('\t\t\t\t\tTable 1\n'));

fprintf(fid,'\t\t\t\tMISSION :');
fprintf(fid,' ');
fprintf(fid,Mission);

LBFM = 0;
while LBFM > 5 || LBFM < 1
LBFM = round(rand*10);
end
for i = 1: 1: LBFM
fprintf(fid,'\n');
end

fprintf(fid,'FIRST MOTION REAL TIME:');
fprintf(fid,' ');
fprintf(fid,FirstMotionTime_str);
fprintf(fid,'LAUNCH POINT:\t\t');
fprintf(fid,LaunchPoint_str);
fprintf(fid,'DIRECTION:\t\t');
fprintf(fid,Direction);
fprintf(fid,'\n\n');

fprintf(fid,'METEROLOGICAL DATA\n\n');

fprintf(fid,'TEMPERATURE 0.00 F\n');
fprintf(fid,'RELATIVE HUMIDITY 0.00');
fprintf(fid,' ');
fprintf(fid,'%%');
fprintf(fid,'\n');
fprintf(fid,'DEW POINT   0.00\n');
fprintf(fid,'BAROMETRIC PRESSURE 0.00 IN/HG\n');
fprintf(fid,'WIND SPEED 0.00 KNOTS\n');
fprintf(fid,'WIND DIRECTION 0.00 DEG\n');
fprintf(fid,'BURN-OUT WEIGHT 0.00 LBS\n');
fprintf(fid,'FRONTAL AREA    0.00 SQ FT\n\n');

fprintf(fid,'PARALLEL EVENT TIME LISTING\n\n');

fprintf(fid,'FUNCTION\tLOCATION\tREAL TIME\t\tGENERAL TIME\tVELOCITY\n');
fprintf(fid,'\t\t(');
fprintf(fid,'feet)\t\t\t\t\t\t\t(');
fprintf(fid,'ft/sec)\n');

for i = 1:1:size(TABLE1,1)
fprintf(fid,char(TABLE1(i,1)));
fprintf(fid,'\t\t');
fprintf(fid,char(TABLE1(i,2)));
fprintf(fid,'\t\t');
fprintf(fid,char(TABLE1(i,3)));
fprintf(fid,'\t');
fprintf(fid,char(TABLE1(i,4)));
fprintf(fid,'\t');
fprintf(fid,char(TABLE1(i,5)));
fprintf(fid,'\n');
end
fprintf(fid,'FB MON');
fprintf(fid,'\t\t');
FBTS = str2double(regexprep(LaunchPoint_str,'\\n','')) - (Trav_pol * 1000);
fprintf(fid,num2str(FBTS));
fprintf(fid,'\t\t');
fprintf(fid,regexprep(FirstMotionTime_str,'\\n',''));
fprintf(fid,'\t');
fprintf(fid,'00:00:00:000');
fprintf(fid,'\t');
fprintf(fid,'0.00');
fprintf(fid,'\n\n\n');

fclose(fid);


TABLE1 = cell2table(TABLE1);
TABLE1.Properties.VariableNames = {'Function' 'TS' 'Time' 'GT' 'Velocity'};
TABLE1.TS = str2double(TABLE1.TS);
TABLE1.Velocity = str2double(TABLE1.Velocity);
TABLE1.GT = [];
TABLE1.Time = strcat(num2str(year),':',TABLE1.Time);
for i=1:1:size(TABLE1.Time)
    TABLE1Time(i,1) = Tbl1JDTtoNorm(char(TABLE1.Time(i)));
end
TABLE1.Time = TABLE1Time;


