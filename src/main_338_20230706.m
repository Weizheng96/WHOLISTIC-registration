%% 20230620, Wei Zheng
clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));

%% file path
filePath="/work/public/Virginia Rutten/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/" + ...
    "exp0/imag/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_7dpf002.nd2";

resPathName="/work/public/Virginia Rutten/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/f338_HZRv2d2_r5_p0d01_20230726";
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
% T=500;
r=option.r;
xG=r+1:2*r+1:X;yG=r+1:2*r+1:Y;zG=1:Z;
%% motion correction
tRange=1:frameJump:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength],"single");

option.motion=zeros([X,Y,Z,3]);
dat_ref=readOneFrame_single(reader,1,2);
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
    dat_mov=readOneFrame_single(reader,t,2);
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
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(readOneFrame_double(reader,t,1),motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % motion correction
    disp("initialize motion...");
    [motion_history,BestMotion]=updateMotionHistory(motion_current,motion_history);
    option.motion=BestMotion;
    % save motion
    disp("save motion...");
    motion=motion_current(xG,yG,zG,:);
    save(motionResPathName+"/motion_"+t+".mat","motion","-v7.3");
    % save result
    disp("save result...");
    temp=dat_corrected1(:,:,:,tCnt);
    resName=dataResPathName+"/dat_t"+t+".hdf5";
    if exist(resName)
        delete(resName);
    end
    h5create(dataResPathName+"/dat_t"+t+".hdf5","/ch1",size(temp));
    h5write(dataResPathName+"/dat_t"+t+".hdf5","/ch1",temp);
    % save corrected ch2
    dat=dat_corrected2(:,:,:,tCnt);
    save(fullfile(correctedPathName,"dat_t"+t+".mat"),"dat");
    % save difference between template and current
    dat=dat_ref-dat_mov;
    save(fullfile(correctedPathName,"diff_t"+t+".mat"),"dat");
    toc;
end
%% save the first result
disp("save result (1)...");
cd(resPathName);
out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');
