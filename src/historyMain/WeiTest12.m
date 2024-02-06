clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v17_MedianInitalize";

option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;
refLength=11;
initialLength=5;
%%
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);

tRange=1:20:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength]);

option.motion=[];
for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data...");
    dat_mov=readOneFrame_double(reader,t,2);
    toc;
    % get reference image
    disp("generate reference...");
    if tCnt>refLength
        refRange=(tCnt-refLength):(tCnt-1);
        dat_ref=double(median(dat_corrected2(:,:,:,refRange),4));
    else
        dat_ref=readOneFrame_double(reader,1,2);
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotion_Wei_v17(dat_mov,dat_ref,smoothPenalty,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(readOneFrame_double(reader,t,1),motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % motion correction
    disp("initialize motion...");
    [motion_history,BestMotion]=updateMotionHistory(motion_current,motion_history);
    option.motion=BestMotion;
    toc;
end
%%
% z=4;
% vid2=(squeeze(double(dat_corrected2(:,:,z,:)))-100)/200;
% implay(vid2)
%
% implay(double(dat_ref)/300)
% implay(double(dat_mov)/300)
% implay(double(dat_corrected2(:,:,:,tCnt))/300)
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
disp("save result...");
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
cd(resPathName);

% dat_corrected1=reshape(dat_corrected1,X,Y,Z,1,length(tRange));
% dat_corrected2=reshape(dat_corrected2,X,Y,Z,1,length(tRange));
% 
% for z=1:Z
%     disp(z);
%     bfsave(dat_corrected1(:,:,z,:,:), ['Ch1_z' num2str(z) '_Corrected.ome.tiff']);
% end
% for z=1:Z
%     disp(z);
%     bfsave(dat_corrected2(:,:,z,:,:), ['Ch2_z' num2str(z) '_Corrected.ome.tiff']);
% end

out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');