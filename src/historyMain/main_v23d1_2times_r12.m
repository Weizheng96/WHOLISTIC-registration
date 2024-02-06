clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/ssd1/Pubilic Data/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

anaFilePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/anat/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf001.nd2";

anaCorrectedPath="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/ref/" + ...
    "ref_ch2_corrected.ome.tiff";

correctedFileName="/ssd1/Wei/230119_f389/230119_f389-230216-2Dv2_jump20_penalty1/Corrected.ome.tiff";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/" + ...
    "230119_f389-230216-v23d1_jump20_penalty10_r12_2times";

option.larer=3;
option.iter=10;
option.r=12;
smoothPenalty=100;
refLength=5;
refJump =2;
initialLength=5;
smFactor=50;
thresFactor=5;
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

reader = bfGetReader(convertStringsToChars(correctedFileName));

option.zRatio=option.zRatio_ref;

tRange=1:333;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");

dat_ref_norm=getHighFrequencyComponent(dat_ref,smFactor);
option.mask_ref=getMask(dat_ref_norm,thresFactor);
muRef=mean(dat_ref_norm,'all');sigmaRef=std(dat_ref_norm,0,'all');
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
    disp("normalize data (1)...");
    dat_mov=resizeMov(dat_mov_Raw,Z,option);
    dat_mov_norm=getHighFrequencyComponent(dat_mov,smFactor);
    dat_mov_norm=meanStdNormalization(dat_mov_norm,muRef,sigmaRef);
    option.mask_mov=getMask(dat_mov_norm,thresFactor)&mask_movPad;
    toc;
    % motion correction
    disp("correct motion...");
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