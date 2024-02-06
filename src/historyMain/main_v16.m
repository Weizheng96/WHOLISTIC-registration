clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230215-v16";

option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;
refLength=21;
%%
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);

tRange=1:5:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");


for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data...");
    dat_mov=readOneFrame_double(reader,t,2);
    % get reference image
    disp("generate reference...");
    if tCnt>refLength
        refRange=(tCnt-refLength):(tCnt-1);
        dat_ref=median(double(dat_corrected2(:,:,:,refRange)),4);
    else
        dat_ref=readOneFrame_double(reader,1,2);
    end
    % motion correction
    disp("correct motion...");
    motion_current=getMotion_Wei_v16(dat_mov,dat_ref,smoothPenalty,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(readOneFrame_double(reader,t,1),motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
end
%%
% z=4;
% vid1=(squeeze(double(dat(:,:,z,:)))-100)/200;
% vid2=(squeeze(double(dat_corrected2(:,:,z,:)))-100)/200;
% implay(cat(2,vid1,vid2))
% 
% vid1=(squeeze(double(dat1(:,:,z,:)))-100)/200;
% vid2=(squeeze(double(dat_corrected1(:,:,z,:)))-100)/200;
% implay(cat(2,vid1,vid2))
% 
% implay(double(readOneFrame_double(reader,1,2))/300)
%
% implay(double(dat_ref)/300)
% implay(double(dat_mov)/300)
% implay(double(dat_corrected2(:,:,:,5))/300)
% 
% implay(double(dat2(:,:,:,tCnt))/300)
% %
% IntOrdRef=sort(dat_ref(:));
% dat_mov_normalized=histogramNormalize(dat_mov,IntOrdRef);
% 
% edges=0:1:300;
% histogram(dat_mov_normalized(:),edges);
% hold on;
% histogram(dat_ref(:),edges);
% hold off;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
cd(resPathName);

out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'Original_Corrected2.ome.tiff');
