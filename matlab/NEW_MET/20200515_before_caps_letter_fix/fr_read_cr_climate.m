function [tv,climateData] = fr_read_cr_climate(wildCard,dateIn,chanInd)
% fr_read_cr_climate - extract all or selected data from a csi file
% 
% [tv,climateData] = fr_read_cr_climate(wildCard,dateIn,chanInd)
%
% Inputs:
%       wildCard - full file name including path. Wild cards accepted
%       dateIn   - time vector to extract.  [] extracts all data
%       chanInd  - channels to extract. [] extracts all
%
% Zoran Nesic           File Created:      Apr 21, 2005
%                       Last modification: Apr 21, 2005



h = dir(wildCard);
x = findstr('\',wildCard);
pth = wildCard(1:x(end));
dateIn = fr_round_hhour(dateIn);

climateData = [];
for i=1:length(h)
    disp(sprintf('Loading: %s', [pth h(i).name]));
    dataInNew = textread([pth h(i).name],'','delimiter',',');
    disp(sprintf('  Length = %f\n',size(dataInNew,1)))
    climateData = [climateData ; dataInNew];
end

if ~exist('chanInd') | isempty(chanInd)
    chanInd = 1:size(climateData,2);
end

tv = fr_round_hhour(fr_csi_to_timevector(climateData(:,2:4)));
[tv,indSort] = sort(tv);
climateData = [climateData(indSort,chanInd)];

if exist('dateIn') & ~isempty(dateIn)
    [junk,junk,indExtract] = intersect(dateIn,tv );
else
    indExtract = 1:size(tv,1);
end
   
tv = tv(indExtract);
climateData = climateData(indExtract,:);


function tv = fr_csi_to_timevector(csiTimeMatrix)
tv = datenum(csiTimeMatrix(:,1),1,csiTimeMatrix(:,2),fix(csiTimeMatrix(:,3)/100),(csiTimeMatrix(:,3)/100 - fix(csiTimeMatrix(:,3)/100))*100,0);
