function ta_shortcuts
currChar = get(gcf,'CurrentCharacter');
if ~isletter(currChar)
   return
end
switch lower(currChar)
case 'z'
   TA_contextmenu('zoom');
case 'f'   
   %for various reasons, implementing accelarator keys for the contextmenu "fullview"
   %option caused errors if pressed too quickly.  This is an unimportant problem so
   %a quick fix is a small delay of about 0.5 seconds:
   setdiff(rand(3000,1),rand(3000,1));
   TA_contextmenu('fullview');
case 's'   
   TA_filemenu('save_mat_file');
case 'q' 
   TA_filemenu('terminate');
end



