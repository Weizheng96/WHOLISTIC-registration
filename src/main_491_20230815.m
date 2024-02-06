%% 20230731, add motion foreground, Wei Zheng
clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));

%% file path
filePath="/work/public/Virginia Rutten/230521_f491_ubi_gcamp_bactin_mCherry_10278_7dpf_tricaine/exp0/imag/" + ...
    "2305211_f491_ubi_gcamp_bactin_mCherry_10278_7dpf_tricaine001.nd2";

resPathName="/work/public/Virginia Rutten/230521_f491_ubi_gcamp_bactin_mCherry_10278_7dpf_tricaine/f491_HZRv2d2_r5_p0d01_20230815";
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
zFG=2;
DilateSZ=20;
%% generate the folder
dataResPathName=resPathName+"/hdf5";
motionResPathName=resPathName+"/motion";
correctedPathName=resPathName+"/corrected";
if ~exist(dataResPathName,"dir")
    mkdir(dataResPathName);
end
if ~exist(motionResPathName,"dir")
    mkdir(motionResPathName);
end
if ~exist(correctedPathName,"dir")
    mkdir(correctedPathName);
end
%% get valid z slice in moving image
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);
r=option.r;
xG=r+1:2*r+1:X;yG=r+1:2*r+1:Y;zG=1:Z;
%% motion correction
tRange=1:frameJump:T;

% dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength],"single");
invalidRegion_history=zeros([X,Y,Z,length(tRange)],"logical");

option.motion=zeros([X,Y,Z,3]);
dat_ref=readOneFrame_single(reader,1,2);
option.mask_ref=getMask(dat_ref,thresFactor);
option.mask_ref=bwareafilt3_Wei(option.mask_ref,maskRange);
FG=getMotionForeground(dat_ref,zFG,DilateSZ);
option.mask_ref=option.mask_ref|(~FG);
Pnltfactor=getSmPnltNormFctr(dat_ref,option);
smoothPenalty=Pnltfactor*smoothPenalty_raw;

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov=readOneFrame_single(reader,t,2);
    option.mask_mov=getMask(dat_mov,thresFactor);
    option.mask_mov=bwareafilt3_Wei(option.mask_mov,maskRange);
    FGmov=getMotionForeground(dat_mov,zFG,DilateSZ);
    option.mask_mov=option.mask_mov|(~FGmov);
    toc;
    % get reference image
    disp("generate reference...");
    if mod(tCnt-1,refJump)==0 && tCnt>refLength*refJump
        refRange=(tCnt-refLength*refJump):refJump:(tCnt-refJump);
        dat_ref=single(median(dat_corrected2(:,:,:,refRange),4));
        ref_invalidRegion=max(invalidRegion_history(:,:,:,refRange),[],4);

        option.mask_ref=getMask(dat_ref,thresFactor);
        option.mask_ref=bwareafilt3_Wei(option.mask_ref,maskRange);
        FG=getMotionForeground(dat_ref,zFG,DilateSZ);
        option.mask_ref=option.mask_ref|ref_invalidRegion;
        Pnltfactor=getSmPnltNormFctr(dat_ref,option);
        smoothPenalty=Pnltfactor*smoothPenalty_raw;
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotionHZR_Wei_v2d2(dat_mov,dat_ref,smoothPenalty,option);
    temp=correctMotion_Wei_v2(readOneFrame_double(reader,t,1),motion_current);
    [dat_corrected2(:,:,:,tCnt),~,~,~,invalidRegion_history(:,:,:,tCnt)]=correctMotion_Wei_v4(dat_mov,motion_current);
    toc;
    % motion correction
    if mod(tCnt-1,refJump)==0
        disp("initialize motion...");
        [motion_history,BestMotion]=updateMotionHistory(motion_current,motion_history);
        option.motion=BestMotion;
        toc;
    end
    % save result
    disp("save motion...");
    motion=motion_current(xG,yG,zG,:);
%     save(motionResPathName+"/motion_"+t+".mat","motion","-v7.3");

    disp("save result...");
    ImName=num2str(t-1,"%05.f");
    resName=dataResPathName+"/dat_t"+ImName+".hdf5";
    if exist(resName)
        delete(resName);
    end
%     h5create(resName,"/ch1",size(temp));
%     h5write(resName,"/ch1",temp);

    dat=dat_corrected2(:,:,:,tCnt);
%     save(fullfile(correctedPathName,"dat_t"+t+".mat"),"dat");
%     save(fullfile(correctedPathName,"FG_t"+t+".mat"),"FGmov");
    toc;
end
%% save the first result
disp("save result (1)...");
cd(resPathName);
zRatio=option.zRatio;
save("opt.mat","r","zRatio","X","Y","Z","T","frameJump","smoothPenalty_raw");
for z=1:Z
    dat_org=readOneSliceWithTime(reader,z,tRange,2);
    dat_cor=squeeze(dat_corrected2(:,:,z,:));
    out2=reshape([dat_org dat_cor],X,2*Y,1,1,length(tRange));
    bfsave(out2,['OC_z' num2str(z) '.tiff']);
end