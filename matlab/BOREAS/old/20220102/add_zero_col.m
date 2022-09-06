function x = add_zero_col(pth,file_name,ind,filesize)
%
% add_zero_col('\\annex_001\d\database\pa_dbase\','avgbr.',121:180,size(x));
%
%
z = zeros(filesize(1),filesize(2));
for i=ind;
    f1 = save_bor([pth file_name num2str(i)], 1, z);
end