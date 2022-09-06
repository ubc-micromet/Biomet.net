function extraCalculations = fr_calc_extraCalculations(configIn,num,level,dataIn,miscVariables,stats,EngUnits);

% Calculate extra system computations eg. Spectra, spikes, stationarity, response time, etc.
%
% E. Humphreys  June 13, 2002
%
% Revisions: May 25, 2003 - check if the extra calc routine actually outputs anything before setting the 
%								field output (line 21)


extraCalculations = [];
for currentVariable = 1:length(getfield(configIn.ExtraCalculations,{1},level))   % cycle for each calculation set
   
   if getfield(configIn.ExtraCalculations,{1},level,{currentVariable},'ON') == 1
      
      for i = 1:length(getfield(configIn.ExtraCalculations,{1},level,{currentVariable},'Execute'))
         eval(char(getfield(configIn.ExtraCalculations,{1},level,{currentVariable},'Execute',{i})));
      end
      
      
      if exist(char(getfield(configIn.ExtraCalculations,{1},level,{currentVariable},'Name')));
         extraCalculations = setfield(extraCalculations,...
            char(getfield(configIn.ExtraCalculations,{1},level,{currentVariable},'Name')),...
            eval(char(getfield(configIn.ExtraCalculations,{1},level,{currentVariable},'Name'))));
      end
      
      
   end % if SystemLevel(j).ON == 1
   
end % for 

