function site_characteristics = read_site_characteristics(filename)
% site_characteristics = read_site_characteristics(filename)

[names,values] = textread(filename,'%32s%s','whitespace','\n\t');

for i = 1:length(values)
    % Replace 'bad' chars
    var_name = char(names(i));
    ind = find(var_name == ' ' | var_name == '-');
    var_name(ind) = '_';

    % Identify the various types of entries
    var_value = char(values(i));
    if      var_value(1) == '''' & var_value(end) == ''''
        eval(['site_characteristics.' var_name ' = var_value(2:end-1);']);
    else 
        ind = find(var_value == ' '); 
        if isempty(ind)
            eval(['site_characteristics.' var_name ' = ' var_value ';']);
        else
            eval(['site_characteristics.' var_name ' = ' var_value(1:ind) ';']);
            eval(['site_characteristics.units.' var_name ' = ''' var_value(ind+1:end) ''';']);
        end
    end
end
