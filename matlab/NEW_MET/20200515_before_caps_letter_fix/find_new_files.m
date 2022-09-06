function lst_diff = find_new_files(lst_old,lst_new)
% lst_diff = find_new_files(lst_old,lst_new)
%
%   pth     - where to look for files
%   lst_old - files that were there before
%   wc      - wild card for new files
%
% Aug 14, 2003 - kai* 

if isempty(lst_old)
   [dum,ind] = sort({lst_new(:).name}');
   lst_diff = lst_new(ind);
	return   
end
   
% Find files in new list that are not in old list
[dum,ind_diff] = setdiff([{lst_new(:).name}],[{lst_old(:).name}]);

% Find files in new list that newer than in old list
[dum,ind_new,ind_old] = intersect({lst_new(:).name},{lst_old(:).name});

if isempty(ind_new)
    lst_diff = lst_new;
else
    ind_update = find( datenum(char({lst_new(ind_new).date}')) > datenum(char({lst_old(ind_old).date}')) );
    lst_diff = [lst_new(ind_diff); lst_new(ind_new(ind_update))];
end

if ~isempty(lst_diff)
   [dum,ind] = sort({lst_diff(:).name}');
   lst_diff = lst_diff(ind);
end


