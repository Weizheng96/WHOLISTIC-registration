clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v21_jump20_penalty5";

option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=5;
refLength=5;
refJump =2;
initialLength=5;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% first registration
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);

tRange=1:20:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength]);

option.motion=[];
dat_ref=readOneFrame_double(reader,1,2);

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov=readOneFrame_double(reader,t,2);
    toc;
    % get reference image
    disp("generate reference...");
    if tCnt>refLength*refJump && mod(tCnt,refJump)==1
        refRange=(tCnt-refLength*refJump):refJump:(tCnt-1);
        dat_ref=double(median(dat_corrected2(:,:,:,refRange),4));
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotion_Wei_v21(dat_mov,dat_ref,smoothPenalty,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(readOneFrame_double(reader,t,1),motion_current);
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
disp("save result (1)...");
cd(resPathName);
out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');