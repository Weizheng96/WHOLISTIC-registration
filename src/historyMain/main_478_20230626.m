%% 20230620, Wei Zheng
clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));

%% file path
filePath="/work/public/Virginia Rutten/230324_f478_ubi_gcamp_bactin2_mcherry_9dpf_hypoxia_tiles/mat";
resPathName="/work/public/Virginia Rutten/230324_f478_ubi_gcamp_bactin2_mcherry_9dpf_hypoxia_tiles" + ...
    "/f478_HZRv2d2_r5_p0d01_20230626";
%% parameters
option.layer=3;
option.iter=10;
option.r=5;
smoothPenalty_raw=0.01;

frameJump=1;
refLength=5;
refJump =40/frameJump;
initialLength=5;
thresFactor=5;
smFactor=50;
maskRange=[5 500];
%% generate the folder
dataResPathName=resPathName+"/hdf5";
motionResPathName=resPathName+"/motion";
if ~exist(dataResPathName,"dir")
    mkdir(dataResPathName);
end
if ~exist(motionResPathName,"dir")
    mkdir(motionResPathName);
end
%% get valid z slice in moving image
cd(filePath);
load("dat1.mat","dat_ch2");
[X,Y,Z]=size(dat_ch2);
T=4814;option.zRatio=13.8462;
%% motion correction
tRange=1:frameJump:T;

% dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_uncorrected2=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength],"single");

option.motion=zeros([X,Y,Z,3]);
dat_ref=single(dat_ch2);
option.mask_ref=getMask(dat_ref,thresFactor);
option.mask_ref=bwareafilt3_Wei(option.mask_ref,maskRange);
Pnltfactor=getSmPnltNormFctr(dat_ref,option);
smoothPenalty=Pnltfactor*smoothPenalty_raw;

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    load("dat"+t+".mat","dat_ch1","dat_ch2");
    dat_mov=single(dat_ch2);
    option.mask_mov=getMask(dat_mov,thresFactor);
    option.mask_mov=bwareafilt3_Wei(option.mask_mov,maskRange);
    toc;
    % get reference image
    disp("generate reference...");
    if mod(tCnt-1,refJump)==0
        if tCnt>refLength*refJump
            refRange=(tCnt-refLength*refJump):refJump:(tCnt-refJump);
            dat_ref=single(median(dat_corrected2(:,:,:,refRange),4));
        end
%         dat_ref=updateFloatingTemplate_v3(dat_ref,dat_anaref_norm,thresFactor,optionTemplate,smoothPenaltyTemplate);
        option.mask_ref=getMask(dat_ref,thresFactor);
        option.mask_ref=bwareafilt3_Wei(option.mask_ref,maskRange);
        Pnltfactor=getSmPnltNormFctr(dat_ref,option);
        smoothPenalty=Pnltfactor*smoothPenalty_raw;
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotionHZR_Wei_v2d2(dat_mov,dat_ref,smoothPenalty,option);
    temp=correctMotion_Wei_v2(single(dat_ch1),motion_current);
    dat_uncorrected2(:,:,:,tCnt)=dat_mov;
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % motion correction
    disp("initialize motion...");
    [motion_history,BestMotion]=updateMotionHistory(motion_current,motion_history);
    option.motion=BestMotion;
    toc;
    % save motion
    disp("save motion...");
    save(motionResPathName+"/motion_"+t+".mat","motion_current");
    toc;
    % save result
    disp("save result...");
%     temp=dat_corrected1(:,:,:,tCnt);
    resName=dataResPathName+"/dat_t"+t+".hdf5";
    if exist(resName,"file")
        delete(resName);
    end
%     temp=dat_corrected1(:,:,:,tCnt);
    h5create(dataResPathName+"/dat_t"+t+".hdf5","/ch1",size(temp));
    h5write(dataResPathName+"/dat_t"+t+".hdf5","/ch1",temp);
    toc;
end
%% save the first result
reset(gpuDevice());
disp("save result (1)...");
cd(resPathName);
% bfsave(cat(2,dat_uncorrected2,dat_corrected2), 'Original_Corrected.ome.tiff');
bfsave(dat_uncorrected2, 'Original.ome.tiff');
bfsave(dat_corrected2, 'Corrected.ome.tiff');
%% debug
% raw=squeeze(double(dat_uncorrected2(:,:,7,1:tCnt)));
% new=squeeze(double(dat_corrected2(:,:,7,1:tCnt)));
% implay(mat2gray([raw new])*20);