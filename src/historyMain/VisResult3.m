clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parametersresPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v21_jump20_penalty1";
filePath="/ssd1/Pubilic Data/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v20_jump20_penalty1";

reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,~,T,~,~]=readMeta(reader);
tRange=1:20:T;

z_vis=3;

%% read data
c=2;
dat_raw=double(readOneSliceWithTime(reader,z_vis,tRange,c));
%% read motion
Trange=length(tRange);
Ulst=cell(1,Trange);Vlst=cell(1,Trange);
tic;
parfor tCnt=1:Trange
    disp(tCnt+"/"+Trange);
    t=tRange(tCnt);
    [U,V]=readOneZsliceMotion(resPathName+"/motion_"+t+".mat",z_vis);
    Ulst{tCnt}=U;Vlst{tCnt}=V;
end
toc;
%% get grid
r=5;
xG=r+1:2*r+1:X;yG=r+1:2*r+1:Y;
[GridY,GridX] = meshgrid(yG,xG);
UGridlst=cell(1,Trange);VGridlst=cell(1,Trange);
parfor tCnt=1:Trange
    disp(tCnt+"/"+Trange);
    UGridlst{tCnt}=Ulst{tCnt}(xG,yG)+GridX;
    VGridlst{tCnt}=Vlst{tCnt}(xG,yG)+GridY;
end
%% plot
dat=(dat_raw-80)/170;
% figure;
for tCnt=1:51%1:Trange
    disp(tCnt+"/"+Trange)
%     imshow(dat(:,:,tCnt));
    gridMotion(dat(:,:,tCnt),UGridlst{tCnt},VGridlst{tCnt});
    title("t="+(tRange(tCnt)-1));
    pause(0.1);
end
