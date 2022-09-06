function fcrn_rename_nb_nl(currentDate)

arg_default('currentDate',floor(now));

dirDate = fr_datetofilename(currentDate+1/48);
dirDate = dirDate(1:6);

if strcmp(fr_get_pc_name,'XSITE01')
    pth_base = 'D:\Experiments\NB_NL\met-data\data';
else
    pth_base = 'D:\kai_data\Projects_data\XSITE\Experiments\NB_NL\Met-data\data';
end

pth_in  = fullfile(pth_base,'CardDump',dirDate);
pth_out = pth_base;

lst = dir(fullfile(pth_in,'NB_Nl.*'));

for i = 1:length(lst)
    x = textread(fullfile(pth_in,lst(i).name),'%q',1,'headerlines',40);
    tv(i) = datenum(sscanf(char(x),'%4d-%2d-%2d %2d:%2d:%2d')');
    
    filename = fr_datetofilename(fr_round_hhour(tv(i),2));

    if exist(fullfile(pth_out,filename(1:end-2))) ~= 7
        mkdir(pth_out,filename(1:end-2));
    end
    
    copyfile(fullfile(pth_in,lst(i).name),fullfile(pth_out,filename(1:end-2),[filename '.dNB_NL']));
    disp(fullfile(pth_in,lst(i).name));
    
end