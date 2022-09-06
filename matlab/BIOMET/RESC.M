
str=input('Coordinate files(figs and mags)ready or right? say y or n ','s');
load figs
load mats
co=figs;
sc=mats; 
if(str=='n')
   break
end
in_name= input('Give input line-file name ,line#  ','s')
eval(['load ' in_name ';']);
eval(['xy= ' in_name ';']); 
out_name=input('Give output table-file name ,table#  ','s') 
control=input('Table-file exist or not ?  say y or n ','s');
if(control=='n')
tr=input('A new file will be created? Are you sure? say y or n ','s');
  if(tr=='n')
    break
  end
  clear tb;
end
m=input('which column you want to put the line-file in, give a number?  ');
A1=[1 1 1]; 
A=[A1' sc(1:3,1:2)]; 
AX=[co(1:3,1)]; 
AY=[co(1:3,2)];
AX0=inv(A)*AX;  
AY0=inv(A)*AY;  
nb=length(xy);
for i=1:nb
  B=[1 xy(i,1) xy(i,2)];
  x2(i,1)=B*AX0;
  x2(i,2)=B*AY0;
end


 result=[x2(1:nb,1) x2(1:nb,2)]
if(control=='y')
  eval(['load ' out_name ';']) 
end
eval(['save -ascii ' out_name ' result' ]); 
