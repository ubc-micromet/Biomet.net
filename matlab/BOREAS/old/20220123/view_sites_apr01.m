function view_sites_apr01
if exist('c:\apr1.txt'),
    if exist('c:\apr2.txt')
%        delete('c:\apr1.txt')
%        delete('c:\apr2.txt')
        return
    else
        fid=fopen('c:\apr2.txt','w');
        fclose(fid)
    end
else
    fid=fopen('c:\apr1.txt','w');
    fclose(fid)
end    


view_sites_addon_apr01('Name','Remove Windows XP')
view_sites_addon1_apr01('Name','Killing XP')
areyousure_apr01