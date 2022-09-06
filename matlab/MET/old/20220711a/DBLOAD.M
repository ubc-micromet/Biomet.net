function dataout = dbload(road,database,var,maxchan);
%*****************************************************************%
% THIS MATLAB FUNCTION READS BOREAS DATA INTO MATLAB              %
% AND READS ONLY DATA WHERE QUALITY FLAG IS UP                    %
%                                                                 %
%    dataout = dbload(road,database,var,maxchan)                  %
%    road (path) & database in quotes !                           %
%    eg solar=dbload('j:\data','meaes',13)                        %
%                                                                 %
% DATABASE ID:  1 = SNUBC(49)  7 = DEUBC(41) 13 = SRC(52)         %
% (max # chan)  2 = TRUBC(54)  8 = HFUBC(88) 14 = SOUBC(60)       %
%               3 = MEAES(53)  9 = TPAES(69) 15 = SHUBC(6)        %
%               4 = MFUBC(15) 10 = TPUBC(35) 16 = CPAES(10)       %
%               5 = LIUBC(?)  11 = PRAES(24) 17 = IRUBC           %
%               6 = L2UBC(11) 12 = FFAES(9)  18 = (TAB)           %
%                                                                 %
% VARIABLE ID: Sorry, too much to write - see keytable            %    
% *********FOR NOW HFUBC FROM P2 - WITH ROTATTION !!! *********   %
%                                                                 %
%*****************************************************************%

if database == 'src  ';       
    VarFileName = [road '\' sscanf(database,'%s',3) '\' sscanf(database,'%s',3) '.' num2str(var)];
        elseif database == 'trubc';
            VarFileName = [road '\' database '\' database '_' num2str(var)];
        elseif database == 'snubc';
            VarFileName = [road '\' database '\' database '_' num2str(var)];
        elseif database == 'hfubc';
        %    rotation = input('Select 1 for page 1 (no rotation); 2 for page 2 (rotated):  ');
        %        if rotation == 1;
        %            VarFileName = [road '\' database '\' database '_' num2str(var) '.1_2'];
        %            elseif rotation == 2;
                    VarFileName = [road '\' database '\' database '_' num2str(var) '.2_2'];
        %        end;    
        else;    
    VarFileName = [road '\' database '\' database '.' num2str(var)];
end;

dataout = read_bor(VarFileName);

% calculate flag length
FlagLen = ceil(maxchan/8);

% load flag file
if database == 'src  ';       
    FlagFileName = [road '\' sscanf(database,'%s',3) '\' sscanf(database,'%s',3) '_f1'];
    else;
    FlagFileName = [road '\' database '\' database '_f1'];
end;
    
FlagFile = read_bor(FlagFileName,2,FlagLen);

% Read specific variable flag 
VarFlag = get_flag(FlagFile,var);

% Remove missing data according to flag position
ind = find(VarFlag == 0);
dataout(ind) = NaN*ones(1,length(ind));

