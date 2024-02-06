function [z,c,Z,C]=getSliceId3(dat_raw_temp)

% dat_raw_temp=dat_raw2{1};

pat1='; Z=';
pat2='; C=';
% pat3='; T=';
k1 = strfind(dat_raw_temp,pat1);
k2 = strfind(dat_raw_temp,pat2);
% k3 = strfind(dat_raw_temp,pat3);

ZidxStr=dat_raw_temp(k1+length(pat1):k2-1);
CidxStr=dat_raw_temp(k2+length(pat1):end);
% TidxStr=dat_raw_temp(k3+length(pat1):end);

k1 = strfind(ZidxStr,"/");
z=str2double(ZidxStr(1:k1-1));
Z=str2double(ZidxStr(k1+1:end));

k2 = strfind(CidxStr,"/");
c=str2double(CidxStr(1:k2-1));
C=str2double(CidxStr(k2+1:end));

% k3 = strfind(TidxStr,"/");
% t=str2double(TidxStr(1:k3-1));
% T=str2double(TidxStr(k3+1:end));

end