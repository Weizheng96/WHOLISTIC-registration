%% 20230620, Wei Zheng
clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));

%% file path
filePath="/work/public/Virginia Rutten/230324_f478_ubi_gcamp_bactin2_mcherry_9dpf_hypoxia_tiles/mat";
resPathName="/work/public/Virginia Rutten/230324_f478_ubi_gcamp_bactin2_mcherry_9dpf_hypoxia_tiles" + ...
    "/f478_v1.0_20240213";
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
dataResPathName=resPathName+"/hdf5_ch1";
dataResCh2PathName=resPathName+"/hdf5_ch2";
motionResPathName=resPathName+"/motion";
motionDSResPathName=resPathName+"/motion_downsample";


if ~exist(dataResPathName,"dir")
    mkdir(dataResPathName);
end
if ~exist(dataResCh2PathName,"dir")
    mkdir(dataResCh2PathName);
end
if ~exist(motionResPathName,"dir")
    mkdir(motionResPathName);
end
if ~exist(motionDSResPathName,"dir")
    mkdir(motionDSResPathName);
end
%% get valid z slice in moving image
cd(filePath);
load("dat1.mat","dat_ch2");
[X,Y,Z]=size(dat_ch2);
T=4814;option.zRatio=13.8462;
r=option.r;
xG=r+1:2*r+1:X;yG=r+1:2*r+1:Y;zG=1:Z;
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
    %% save result
    disp("save result...");
    ImName=num2str(t-1,"%05.f");
    resName=dataResPathName+"/dat_t"+ImName+".hdf5";
    if exist(resName,"file")
        delete(resName);
    end
    h5create(resName,"/ch1",size(temp));
    h5write(resName,"/ch1",temp);
    % save corrected ch2
    resName=dataResCh2PathName+"/dat_t"+ImName+".hdf5";
    if exist(resName,"file")
        delete(resName);
    end
    dat=dat_corrected2(:,:,:,tCnt);
    h5create(resName,"/ch2",size(dat));
    h5write(resName,"/ch2",dat);
    % save motion
    disp("save motion...");
    resName=motionResPathName+"/dat_t"+ImName+".hdf5";
    if exist(resName,"file")
        delete(resName);
    end
    h5create(resName,"/motion",size(motion_current));
    h5write(resName,"/motion",motion_current);
    % save motion downsampled
    motion=motion_current(xG,yG,zG,:);
    save(motionDSResPathName+"/motion_"+(t-1)+".mat","motion","-v7.3");
    toc;
end
%% save parameters
reset(gpuDevice());
disp("save result parameters...");
zRatio=option.zRatio;
save(fullfile(resPathName,"opt.mat"),"r","zRatio","T","option","smoothPenalty_raw","frameJump","refLength",...
    "maskRange","smFactor","thresFactor","initialLength","refJump","dataResPathName","dataResCh2PathName",...
    "motionResPathName","motionDSResPathName","filePath");