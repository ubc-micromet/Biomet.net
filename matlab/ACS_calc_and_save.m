function [HHour] = ACS_calc_and_save(dateRange,SysNbr,metdataPath,recalcFlag, plotFlag)
%[HHour] = ACS_calc_and_save(dateRange,SysNbr)
%
%
% (c) David Gaumont-Guay & Zoran Nesic           File created:             , 2005
%                                                Last modification   Aug  6, 2007

%Revisions:
%
% Aug 6, 2007
%   - added plotFlag
% July 21, 2007
%   - added TimeVector field to HHour
%   - removed "+VB2MatlabDateOffset" from datestr calculation to get
%     correct date (year 2007 instead of 3907)
% Mar 20, 2007
%   - added an option for plotting (plotFlag = 1)
% Mar 13, 2007
%   - implemented delay time to improve data processing by including the
%   time delay between the chamber is selected and the time air sample
%   arrives to the IRGA

% example of extracting data
% x = get_Stats_field(HHour,'Chamber(1).Sampe(3).airTemperature')

if ischar(dateRange)
    dateRange = eval(dateRange);
end
if ischar(SysNbr)
    SysNbr = eval(SysNbr);
end

if ischar(recalcFlag)
    recalcFlag = eval(recalcFlag);
end

if metdataPath(end) ~= '\'
    metdataPath = [metdataPath '\'];
end

numOfErrors = 0;
numOfFiles = 0;

warning ('off', 'MATLAB:divideByZero');
warning('off','MATLAB:dispatcher:InexactMatch');
VB2MatlabDateOffset = 693960;
delete(fullfile(metdataPath,'log','ACS_calc_and_save.log'));
diary(fullfile(metdataPath,'log','ACS_calc_and_save.log'));
disp('=============================================')
disp(['Calculations started: ' datestr(now)])
disp('   ');

tic;    
for dateRangeCurrent = dateRange

    HHour = [];
    
    %Get inifile information
    configIn  = acs_read_init_all(floor(dateRangeCurrent), SysNbr, metdataPath);

    %Create filename for input and output files
    FileName_p = datestr(datestr(dateRangeCurrent),30);
    FileName_p = FileName_p(3:8);

    disp(sprintf('Processing data in folder: %s',[configIn.path num2str(FileName_p(1:6))]))
    
    % Check if recalculation is needed
    if recalcFlag ~= 1 & ~isempty (dir([configIn.hhour_path FileName_p(1:6) configIn.hhour_ch_ext]));
        disp(['('  FileName_p(1:6) ') ' 'Skipped. HHour data already calculated.']);
    else
        %Find all the files in the current directory that are associated with ACS
        dirInfo = dir([configIn.path num2str(FileName_p(1:6)) '\*' configIn.HF_ext num2str(SysNbr)]);
        numOfFiles = numOfFiles + length(dirInfo);
        
        %Loop through files available in current directory and compute fluxes
        for g = 1:length(dirInfo)    

            hhourNbr = str2num(dirInfo(g).name(7:8))/2;

            %import high frequency data (DataHF)
            fullFileName = [configIn.path num2str(FileName_p(1:6)) '\' dirInfo(g).name];
            [DataHF,header] = fr_read_Digital2_file(fullFileName);

            % find out if the file contains at least a hundred points.
            % There was 
            
            % check if the data has the last point in the next half hour
            % (happens sometimes with UBC_GII program)
            if DataHF(end,6) == 0      % If the last Timer value == 0
                % remove the last sample
                DataHF = DataHF(1:end-1,:);
            end
            
            %Store filename, time stamp (end of hhour) and configuration info in HHour
            HHour(hhourNbr).HhourFileName = dirInfo(g).name;
            HHour(hhourNbr).TimeVector    = header.hhourStartTime;
            HHour(hhourNbr).HhourEndTime  = datestr(header.hhourStartTime);
            HHour(hhourNbr).Configuration = configIn;

            %Store diagnostic results for full halfhour (from DataHF) in HHour
            [m,n] = size(DataHF);
            for j=1:n
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).avg = mean(DataHF(:,j));
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).min = min(DataHF(:,j));
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).max = max(DataHF(:,j));
                HHour(hhourNbr).DataHF.Channel.(char(configIn.chanNames(j))).std = std(DataHF(:,j));
            end

            %Store DataHF in HHour
            HHour(hhourNbr).DataHF.co2 = DataHF(:,configIn.chanMeasured.co2);
            HHour(hhourNbr).DataHF.h2o = DataHF(:,configIn.chanMeasured.h2o);
            HHour(hhourNbr).DataHF.timer = DataHF(:,configIn.chanMeasured.timer);

            %loop through each chamber and each slope and compute fluxes (and associated variables)
            indSlope_all = [];                      % clear the matrix
            indChamber_all = [];                    % clear the matrix
            try        
                for chNbr = 1:configIn.chNbr
                    %Get index for each chamber
                    indSingleChamber = find(ceil(DataHF(:,configIn.chanMeasured.chNbr))==chNbr);
                    indChamber_all(chNbr).indSingleChamber = indSingleChamber;
                    % Find where the border is beteween different slopes
                    indDiff = find(diff(indSingleChamber)>1);
                    
                    % find starting point for each slope
                    indStartPoints = [1 ; indDiff+1];
                                        
                    %Get data for each slope for each chamber based on index
                    %Delay co2 and h2o signals
                    indSingleChamberDelayed = indSingleChamber + configIn.slopeDelay;

                    % Make sure you don't go beyond the last sample
                    indSingleChamberDelayed = indSingleChamberDelayed(find(indSingleChamberDelayed <= m));
                    indChamber_all(chNbr).indSingleChamberDelayed = indSingleChamberDelayed;
                    indChamber_all(chNbr).indSingleChamber = indSingleChamber;
                    
                    % Extract HF data for the delayed signals
                    co2 = DataHF(indSingleChamberDelayed,configIn.chanMeasured.co2);
                    h2o = DataHF(indSingleChamberDelayed,configIn.chanMeasured.h2o);
                    
                    % Extract HF data for non delayed signals
                    airT = DataHF(indSingleChamber,configIn.chanMeasured.airT(chNbr));
                    tTimer = DataHF(indSingleChamber,configIn.chanMeasured.timer);
                    
                    % Get the average air pressure
                    if isempty(configIn.chanMeasured.airP)
                        airP = ones(size(co2))*configIn.pBar;
                    else
                        airP = DataHF(indSingleChamber,configIn.chanMeasured.airP);
                    end

                    %Calculate regression for each slope for each chamber
                    for slopeNbr = 1:length(indStartPoints)
                        if slopeNbr ~= length(indStartPoints)
                            % pick all points between this start point and
                            % one point before the next start point
                            indSlope = indStartPoints(slopeNbr):indStartPoints(slopeNbr+1)-1;
                        else
                            % if processing the last start point pick all
                            % data from the last start point until the last
                            % sample for this chamber
                            indSlope = indStartPoints(slopeNbr):length(indSingleChamber);
                        end
                        indSlope = [indSlope(1)+configIn.slopeSkipStart:indSlope(end)-configIn.slopeSkipEnd];
                        % store the indexing info for the plotting                         
                        indSlope_all(chNbr,slopeNbr).indSlope = indSingleChamber(indSlope);
                        indSlope_all(chNbr,slopeNbr).indSingleChamberDelayed = indSingleChamberDelayed(indSlope);
                        % Store slope related stats
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airTemperature = mean(airT(indSlope));
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airPressure    = mean(airP(indSlope));

                        %Compute regression for each slope
                        [p,r2,sigma,s,fval,regHHour] = polyfit1([1:length(indSlope)]',co2(indSlope),1);

                        %Store regression results in HHour
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt = p(1);
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rsquare = r2;
                        slopeLength = length(indSlope);
                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse = sqrt( sum( (co2(indSlope)'-polyval(p,1:slopeLength)).^2 ) / slopeLength );

                        %Compute and store effluxes in HHour
                        dcdt = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt;
                        airTemperature = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airTemperature;
                        airPressure = HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).airPressure;
                        chVolume = configIn.chVolume(chNbr);
                        chArea = configIn.chArea(chNbr);

                        HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).efflux = airPressure .* chVolume .* dcdt ...
                            ./ (8.3144.*(airTemperature+273.15).*chArea.*(1 +(mean(h2o(indSlope)./1000))));                

                        %Store diagnostic variables for each slope
                        [m1,n1] = size(DataHF(indSingleChamber(indSlope),:));
                        for h=1:n1
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).avg ...
                                                            = mean(DataHF(indSingleChamber(indSlope),h));
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).min ...
                                                            = min(DataHF(indSingleChamber(indSlope),h));
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).max ...
                                                            = max(DataHF(indSingleChamber(indSlope),h));
                            HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).Channel.(char(configIn.chanNames(h))).std ...
                                                            = std(DataHF(indSingleChamber(indSlope),h));
                        end % next h
                    end % next slopeNbr
                end % next chNbr
                if plotFlag == 1
                    test_plot(DataHF,indSlope_all,indChamber_all,HHour,hhourNbr, dirInfo(g).name)
                end 
                disp(sprintf('Processed file: %s.',dirInfo(g).name))
            catch
                numOfErrors = numOfErrors + 1; 
                disp(sprintf('**** Error in file: %s. Error: [%s]',fullFileName,lasterr))
             end % of try-catch
         end % next HF file

        %Export output file
        if ~isempty(dirInfo)
            if ~isempty(HHour)
                FileName = [configIn.hhour_path FileName_p(1:6) configIn.hhour_ch_ext]; 
                save(FileName,'HHour');
            else
                disp('Files exist but data processing failed');
            end
        else
            disp('Files do not exist and data processing failed');
        end
    end
end
disp(sprintf('%0.0f of %0.0f hhour files processed in %4.2f seconds',numOfFiles-numOfErrors,numOfFiles,toc));
disp('   ');
disp('   ');
diary off

function c = acs_read_init_all(dateRange, SysNbr, metdataPath)

c =[];
fid = fopen('acs_init_all.txt');
if fid < 0
    error('Init file: acs_init_all.txt not found!')
end

while 1
    s = fgetl(fid);
    if ~ischar(s),break,end
    eval(s)
end

fclose(fid);

function test_plot(DataHF,indSlope_all,indChamber_all,HHour,hhourNbr,fileName)
    figure(1);
%    ha1=subplot(1,2,1);
%    set(ha1,'position',[0.07 0.11 0.3 0.815]);
    indSlope = indSlope_all(1,1).indSlope;
    co2 = DataHF(:,1);
    tTimer = DataHF(:,6);
    if ~isempty(indSlope)
        for chNbr=1:size(indSlope_all,1)
            plot(tTimer,co2,'.',tTimer(indChamber_all(chNbr).indSingleChamberDelayed),co2(indChamber_all(chNbr).indSingleChamberDelayed),'r.')
            title(sprintf('Chamber = %d, hhour = %d, Data file: %s',chNbr,hhourNbr,fileName))
            indSingleChamber = indChamber_all(chNbr).indSingleChamber;
            line(tTimer(indSingleChamber),co2(indSingleChamber),'marker','o','markeredgecolor','k','linestyle','none');

            for slopeNbr = 1:size(indSlope_all,2)
                indSlope = indSlope_all(chNbr,slopeNbr).indSlope;
                indSlopeDelayed = indSlope_all(chNbr,slopeNbr).indSingleChamberDelayed;
                
                try
%                    disp(sprintf('%d %d %8.4f %8.4f %8.4f',[hhourNbr chNbr
%                    slopeNbr HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).rmse]));
                    line(tTimer(indSlopeDelayed),co2(indSlopeDelayed),'marker','o','markeredgecolor','g','linestyle','none');
                    line(tTimer(indSlopeDelayed),mean(co2(indSlopeDelayed))+detrend((0:length(indSlopeDelayed)-1)*HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt,0));
%                    line(tTimer(indSlopeDelayed),mean(co2(indSlopeDelayed(1:5)))+(0:length(indSlopeDelayed)-1)*HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt);
                    text(tTimer(indSlopeDelayed(round(1))),max(co2(indSlopeDelayed)),sprintf('%5.2f',HHour(hhourNbr).Chamber(chNbr).Sample(slopeNbr).dcdt))
                catch
%                    disp(sprintf('%d %d %d',[hhourNbr chNbr slopeNbr]))
                end
            end
            pause
        end
%        ha2=subplot(1,2,2);
%        set(ha2,'position',[0.44 0.11 0.3 0.815])
    end