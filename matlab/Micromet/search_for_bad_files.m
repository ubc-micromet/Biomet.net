% Search for database files that are of a wrong length 
% (in Jan 2023 there was a bug that created extra entries 
%  and appended them to db files for DSM and BB2 MET folder).
% Zoran used this script to find the folders with the bad data files

for cntID = {'BB','BB2','DSM','RBM'}
    siteID = char(cntID);
    for cntType = {'Met','Flux'}
        dataType = char(cntType);
        for yearIn = 2018:2023
            find_db_files_with_wrong_length(siteID,yearIn,dataType,-1);
            %fprintf('-----------\n');
        end
    end
end



