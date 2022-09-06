function trace_str = readDISCSV(Year,pth)
% berms_out = readDISCSV(pth)
%
% Read FCRN DIS CSV files assumin that all files have the same variables

lst = dir(fullfile(pth,['*_' num2str(Year) '-*.csv']));

if isempty( lst )
   trace_str = [];
   return;
end

% variables names and formats
fileName = fullfile(pth,lst(1).name);
header = textread(fileName,'%s',3);
namesChar = [char(header(1))]; % No of , equals no of columns
unitsChar = [char(header(2))];
dataChar  = [char(header(3))];
namesChar = strrep(namesChar,'#','N');

ind_names = [0 find([char(header(1)) ','] == ',')];
ind_units = [0 find([char(header(2)) ','] == ',')];
ind_data  = [0 find([char(header(3)) ','] == ',')];
n_col = length(ind_names)-1;
% Generate annual hhourly time vector and insert data
tv_year = fr_round_hhour([datenum(Year,1,1,0,30,0):1/48:datenum(Year+1,1,1)]);

for i = 1:n_col
    trace_str(i).TimeVector = tv_year;
    trace_str(i).DOY        = tv_year-datenum(Year,1,0);
    trace_str(i).variableName = namesChar(ind_names(i)+1:ind_names(i+1)-1);
    trace_str(i).ini.units = unitsChar(ind_units(i)+2:ind_units(i+1)-2);
    trace_str(i).data = NaN .* zeros(size(tv_year));
end

% Generate format string using a-priory FCRN format info
t = char(ones(n_col-5,1)*'%f,')'; % Create n_col-5 times %f, 
width_col = diff(ind_data(1:end-1))-1;
formatStr = ['%' num2str(width_col(1)) 's,%' num2str(width_col(2)) 's,%' num2str(width_col(3)) 's,' t(:)' '%3s,%f'];


%Load up the data from pth
for i = 1:length(lst)
    disp(lst(i).name);
    %construct the full file name
	fileName = fullfile(pth,lst(i).name);   	   
    
    eval(['[' namesChar '] = textread(fileName,formatStr,''headerlines'',2);']);
    tv = datenum(Year,1,Day,floor(End_Time/100),mod(End_Time,100),0);
    [tv_dum,ind_year,ind_tv] = intersect(tv_year,tv);    
    
    for j = 1:n_col
        if eval(['isnumeric(' trace_str(j).variableName ')'])
            eval(['trace_str(j).data(ind_year) = ' trace_str(j).variableName '(ind_tv);']);
        else
            eval(['trace_str(j).data = ' trace_str(j).variableName '(1);']);
        end
    end
end

return
