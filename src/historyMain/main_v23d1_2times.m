clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

anaFilePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/anat/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf001.nd2";

anaCorrectedPath="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/ref/" + ...
    "ref_ch2_corrected.ome.tiff";

motionPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/" + ...
    "230119_f389-230216-v20d3_jump20_penalty1_zRatio100";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/" + ...
    "230119_f389-230216-v23d1_jump1000_penalty100_2times";
gpuDevice(1);
option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=100;
refLength=5;
refJump =2;
initialLength=5;
smFactor=50;
maskThres=200;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%%
reader = bfGetReader(convertStringsToChars(anaFilePath));
[~,~,Z,~,~,option.zRatio_ref]=readMeta(reader);

reader = bfGetReader(convertStringsToChars(anaCorrectedPath));
dat_ref=readOneFrame_single(reader,1,1);

reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z_mov,T,~,option.zRatio_mov]=readMeta(reader);

option.zRatio=option.zRatio_ref;

tRange=1:1000:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");

dat_ref_norm=getHighFrequencyComponent(dat_ref,smFactor);
option.mask_ref=imdilate(abs(dat_ref_norm)>maskThres,ones(3));
muRef=mean(dat_ref_norm,'all');sigmaRef=std(dat_ref_norm,0,'all');
mask_movPad=getPadMask(X,Y,Z_mov,Z,option);

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov_Raw=readOneFrame_single(reader,t,2);
    load(motionPathName+"/motion_first_"+t+".mat","motion_current");
    dat_mov_Raw=correctMotion_Wei_v2(dat_mov_Raw,motion_current);
    toc;
    % get reference image
    disp("normalize data (1)...");
    dat_mov=resizeMov(dat_mov_Raw,Z,option);
    dat_mov_norm=getHighFrequencyComponent(dat_mov,smFactor);
    dat_mov_norm=meanStdNormalization(dat_mov_norm,muRef,sigmaRef);
    option.mask_mov=imdilate(abs(dat_mov_norm)>maskThres,ones(3))&mask_movPad;
    toc;
    % motion correction
    disp("correct motion...");
    smoothPenalty=10;
    motion_current=getMotion_Wei_v23d1(dat_mov_norm,dat_ref_norm,smoothPenalty,option);

    dat_ch1=readOneFrame_single(reader,t,1);
    dat_ch1=resizeMov(dat_ch1,Z,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(dat_ch1,motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % motion correction
    % save motion
%     disp("save motion...");
%     save(resPathName+"/motion_"+t+".mat","motion_current");
%     toc;
end

%% save the result
disp("save result (1)...");
cd(resPathName);
out1=reshape(dat_corrected1,X,Y,Z,1,length(tRange));
out2=reshape(dat_corrected2,X,Y,Z,1,length(tRange));
% out=cat(4,out1,out2);save("out.mat","out","-v7.3");
bfsave(cat(4,out1,out2), 'Corrected.ome.tiff');