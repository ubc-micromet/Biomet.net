

%Here's the script for Totem 
try
    fprintf('Started: %s\n',mfilename);
    dataPeriod = floor([datenum(2021,1,1,0,30,0) now]);
    Years = year(datetime(dataPeriod,'convertfrom','datenum'));
    %Years = 2021;
    outputFileName = 'TotemDataForTin.dat';
    pathOut = fullfile('D:\Sites\web_page_weather',outputFileName);

    % Use the following one to export most of the data
    pathTotem = biomet_path('yyyy','UBC_Totem','Clean/ThirdStage'); %sprintf('//annex001/database/%d/UBC_Totem/Climate/Totem1/',yearX);


    % Totem is in GMT.  Output will be in PST so convert the time and truncate
    % the data.
    tv_T  =  read_bor(fullfile(pathTotem,'Clean_tv'),8,[],Years)-8/24;   % GMT -> PST!
    %Ta =  read_bor(fullfile(pathTotem,'air_temperature_main'),[],[],Years);       % Tair
    %RH =  read_bor(fullfile(pathTotem,'relative_humidity_main'),[],[],Years);
    %Tsoil_10 =  read_bor(fullfile(pathTotem,'soil_temperature_10cm'),[],[],Years);
    %Tsoil_20 =  read_bor(fullfile(pathTotem,'soil_temperature_20cm'),[],[],Years);
    %Tsoil_40 =  read_bor(fullfile(pathTotem,'soil_temperature_40cm'),[],[],Years);
    global_radiation_main =  read_bor(fullfile(pathTotem,'global_radiation_main'),[],[],Years);
    precipitation =  read_bor(fullfile(pathTotem,'precipitation_main'),[],[],Years);
    ind = find(tv_T>dataPeriod(1) & tv_T <= dataPeriod(2));
    tv_T = tv_T(ind);
    %Ta = Ta(ind);
    %RH = RH(ind);
    %Tsoil_10 = Tsoil_10(ind);
    %Tsoil_20 = Tsoil_20(ind);
    %Tsoil_40 = Tsoil_40(ind);
    precipitation = precipitation(ind);
    global_radiation_main = global_radiation_main(ind);


    %% fill the gaps:
    % Ta_fill = interp1(tv_T(~isnan(Ta)),Ta(~isnan(Ta)),tv_T);
    % 
    % figure(2)
    % clf
    % plot(tv_T-datenum(Years(1),1,0),[Ta_fill Tsoil_10 Tsoil_20 Tsoil_40]);zoom on;

    %%
    form='%s, %8.2f, %8.2f \n';
    fid=fopen(pathOut,'w');
    %fid=2;
    if fid> 0
        fprintf(fid,'Time stamp is for the end of the measurement period\n');
        fprintf(fid,'Date/Time,     precipitation (mm), global_radiation_main (W)\n');
           for n=1 : max(size(tv_T))
              %fprintf(fid, '%s, %8.2f, %8.2f, %8.2f, %8.2f, %8.2f, %8.2f\n \n \n', datestr(tv_T(n)), Ta_fill(n),RH(n),Tsoil_10(n),Tsoil_20(n),Tsoil_40(n));
              fprintf(fid, '%s, %6.2f, %6.2f \n', datestr(tv_T(n),31),precipitation(n),global_radiation_main(n));
           end
        fclose(fid);
    end
catch
    fprintf('*** Error in: %s ***\n',mfilename);
end
fprintf('Finished: %s\n',mfilename);