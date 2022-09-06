function close_all_Fig_but_200()

    childn = get(0,'children');
    ind = find(childn ~= 200);
    close(childn(ind));
