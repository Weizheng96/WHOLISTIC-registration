clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/230119_f391_ubi_gcamp_bact_mcherry_8849_8dpf_atropine/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_8dpf_atropine001.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f391/test_HZRv2d2_allFrames_twoShot";

option.layer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;

optionTemplate.layer=3;
optionTemplate.iter=10;
optionTemplate.r=12;
smoothPenaltyTemplate=10;


refLength=5;
refJump =40;
initialLength=5;
thresFactor=5;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% first registration
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);

tRange=1:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength]);

option.motion=zeros([X,Y,Z,3]);
dat_ref=readOneFrame_double(reader,1,2);
option.mask_ref=getMask(dat_ref,thresFactor);

dat_ref_fixed=dat_ref;
optionTemplate.mask_ref=option.mask_ref;
optionTemplate.zRatio=option.zRatio;

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov=readOneFrame_double(reader,t,2);
    option.mask_mov=getMask(dat_mov,thresFactor);
    toc;
    % get reference image
    disp("generate reference...");
    if tCnt>refLength*refJump && mod(tCnt,refJump)==1
        refRange=(tCnt-refLength*refJump):refJump:(tCnt-1);
        dat_ref=double(median(dat_corrected2(:,:,:,refRange),4));
        dat_ref=updateFloatingTemplate_v2(dat_ref,dat_ref_fixed,thresFactor,optionTemplate,smoothPenaltyTemplate);
        option.mask_ref=getMask(dat_ref,thresFactor);
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