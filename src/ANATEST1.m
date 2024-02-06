clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

anaFilePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/anat/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf001.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v20d2_jump20_penalty1_highFreq50_maskInt100";

option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;
refLength=5;
refJump =2;
initialLength=5;
smFactor=50;
maskThres=100;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% first registration

reader = bfGetReader(convertStringsToChars(anaFilePath));
[~,~,Z_ref,~,~,option.zRatio_ref]=readMeta(reader);
dat_ref=readOneFrame_double(reader,1,2);

reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio_mov]=readMeta(reader);

option.zRatio=option.zRatio_ref;


t=1;
dat_mov_Raw=readOneFrame_double(reader,t,2);

tic
[dat_mov,mask_movPad]=resizeAndNormalizeMov(dat_mov_Raw,muRef,sigmaRef,Z_ref,option);
toc

option.mask_mov=mask_movPad;
option.mask_ref=false(size(option.mask_mov));

tic;
[motion_current,error]=getMotion_Wei_v23(dat_mov,dat_ref,smoothPenalty,option);
toc

dat_c=correctMotion_Wei_v2(dat_mov,motion_current);

implay(dat_c/300)
