function str = format_dataline(dataline,no_of_siginicant_digits,dlm)

if ~exist('dlm') | isempty(dlm)
   dlm = ',';
end

ind_dat = find(isnan(dataline));
dataline(ind_dat) = -999;

m = length(dataline);
ind = find(dataline~=0);
pres = -Inf.*ones(length(dataline),1);
pres(ind) = ceil(log10(abs(dataline(ind))));
%dataline = round( dataline./(10.^(pres-5))).* (10.^(pres-5));

ind_int   = find(round(dataline') == dataline' | isinf(pres));
ind_large = setdiff(find(pres >=no_of_siginicant_digits),ind_int);
ind_range = setdiff(find(pres<no_of_siginicant_digits & pres>0),ind_int);
ind_small = setdiff(find(pres <=  0),ind_int);

no_pre_str = num2str(pres(ind_large));

no_rem_str = num2str(no_of_siginicant_digits-pres(ind_range));
no_dig_str = num2str(ones(length(ind_range),1)*no_of_siginicant_digits);

no_one_str = num2str(abs(pres(ind_small))+no_of_siginicant_digits+1);
no_all_str = num2str(abs(pres(ind_small))+no_of_siginicant_digits);

form_str(ind_int)   = {['%i' dlm]};

n = length(ind_large);
perc = char(ones(n,1) * '%');
fstr = char(ones(n,1) * ['.0f' dlm]);
form_str(ind_large) = cellstr([perc no_pre_str fstr]);

n = length(ind_range);
perc = char(ones(n,1) * '%');
dots = char(ones(n,1) * '.');
fstr = char(ones(n,1) * ['f' dlm]);
form_str(ind_range) = cellstr([perc no_dig_str dots no_rem_str fstr]);         

n = length(ind_small);
perc = char(ones(n,1) * '%');
dots = char(ones(n,1) * '.');
fstr = char(ones(n,1) * ['f' dlm]);
form_str(ind_small) = cellstr([perc no_one_str dots no_all_str fstr]);

% Remove occurences of e.g. '%8. 7'
form_str = [form_str{:}];
ind = findstr(form_str,'. ')+1;
ind = setdiff(1:length(form_str),ind);
form_str = form_str(ind(1:end-1)); % leave last comma

str = sprintf(form_str,dataline);