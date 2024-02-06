clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/ssd1/Pubilic Data/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

correctedFileName="/ssd1/Wei/230119_f389/230119_f389-230216-2Dv2_jump20_penalty1/Corrected.ome.tiff";
resPathName="/ssd1/Wei/230119_f389/230119_f389-230315-v20d3_jump20_2times_penalty10_r50";

option.larer=3;
option.iter=10;
option.r=50;
smoothPenalty=1;
refLength=5;
refJump =2;
initialLength=5;
motionDecay=1/50;
thresFactor=5;
smFactor=50;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% first registration
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);
reader = bfGetReader(convertStringsToChars(correctedFileName));


tRange=1:333;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");

option.motion=[];
dat_ref=readOneFrame_single(reader,1,2);
dat_ref_norm=getHighFrequencyComponent(dat_ref,smFactor);
option.mask_ref=getMask(dat_ref_norm,thresFactor);
muRef=mean(dat_ref_norm,'all');sigmaRef=std(dat_ref_norm,0,'all');

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+length(tRange));
    % read data
    disp("read data (1)...");
    dat_mov=readOneFrame_single(reader,t,2);
    toc;
    % get reference image
    disp("generate reference...");
    dat_mov_norm=getHighFrequencyComponent(dat_mov,smFactor);
    dat_mov_norm=meanStdNormalization(dat_mov_norm,muRef,sigmaRef);
    option.mask_mov=getMask(dat_mov,thresFactor);
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotion_Wei_v20d4(dat_mov_norm,dat_ref_norm,smoothPenalty,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(readOneFrame_single(reader,t,1),motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % save motion
%     disp("save motion...");
%     save(resPathName+"/motion_first_"+t+".mat","motion_current");
%     toc;
end
%% save the first result
disp("save result (1)...");
cd(resPathName);
out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');