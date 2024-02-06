function [z,t,Z,T]=getSliceId(dat_raw_temp)

pat1='; Z=';
pat2='; T=';
k1 = strfind(dat_raw_temp,pat1);
k2 = strfind(dat_raw_temp,pat2);

ZidxStr=dat_raw_temp(k1+length(pat1):k2-1);
TidxStr=dat_raw_temp(k2+length(pat1):end);

k1 = strfind(ZidxStr,"/");
z=str2double(ZidxStr(1:k1-1));
Z=str2double(ZidxStr(k1+1:end));

k2 = strfind(TidxStr,"/");
t=str2double(TidxStr(1:k2-1));
T=str2double(TidxStr(k2+1:end));

end