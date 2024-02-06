clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

anaFilePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/anat/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf001.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/" + ...
    "230119_f389-230216-v23_jump20_penalty1";

option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;
refLength=5;
refJump =2;
initialLength=5;
smFactor=50;
maskThres=400;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% first registration
reader = bfGetReader(convertStringsToChars(anaFilePath));
[~,~,Z,~,~,option.zRatio_ref]=readMeta(reader);
dat_ref=readOneFrame_single(reader,1,2);

reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z_mov,T,~,option.zRatio_mov]=readMeta(reader);

option.zRatio=option.zRatio_ref;

tRange=1:20:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength]);

option.motion=[];
option.mask_ref=imdilate(abs(dat_ref)>maskThres,ones(3));
muRef=mean(dat_ref,'all');sigmaRef=std(dat_ref,0,'all');

mask_movPad=getPadMask(X,Y,Z_mov,Z,option);

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov_Raw=readOneFrame_single(reader,t,2);
    toc;
    % get reference image
    disp("normalize data data (1)...");
    [dat_mov_norm,dat_mov]=resizeAndNormalizeMov(dat_mov_Raw,muRef,sigmaRef,Z,option);
    option.mask_mov=imdilate(abs(dat_mov_norm)>maskThres,ones(3))&mask_movPad;
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotion_Wei_v23(dat_mov_norm,dat_ref,smoothPenalty,option);

    dat_ch1=readOneFrame_double(reader,t,1);
    dat_ch1=resizeMov(dat_ch1,Z,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(dat_ch1,motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % motion correction
    disp("initialize motion...");
    [motion_history,BestMotion]=updateMotionHistory(motion_current,motion_history);
    option.motion=BestMotion;
    toc;
    % save motion
    disp("save motion...");
%     save(resPathName+"/motion_"+t+".mat","motion_current");
    toc;
end
%% save the result
% disp("save result (1)...");
% cd(resPathName);
% out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
% out1=reshape(out,X,2*Y,Z,1,length(tRange));
% out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
% out2=reshape(out,X,2*Y,Z,1,length(tRange));
% bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');
%% save the result
disp("save result (1)...");
cd(resPathName);
out1=reshape(dat_corrected1,X,Y,Z,1,length(tRange));
out2=reshape(dat_corrected2,X,Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'Corrected.ome.tiff');