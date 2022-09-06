function sites = load_four_sites(years,trace,sites)
% Load traces for the four sites from database into current workspace
% sites = load_four_sites(years,traces,sites)
% Traces is a cellstr array with the names to be loaded as elements
% Sites contains the order of the sites in the data
% The default is sites = ['bs';'cr';'jp';'pa'];

% kai* July 5, 2001 

if ~exist('sites') | isempty(sites)
    sites = ['bs';'cr';'jp';'pa'];
end

no_trc = length(trace);

for i = 1:length(sites)
    get_traces_db(sites(i,:),years,'high_level',trace);
    for j = 1:no_trc
        eval([char(trace(j)) '_arr(:,' num2str(i) ') =  ' char(trace(j)) ';']);
    end
end

for j = 1:no_trc
    eval(['assignin(''caller'',char(trace(j)),' char(trace(j)) '_arr);']);
end

