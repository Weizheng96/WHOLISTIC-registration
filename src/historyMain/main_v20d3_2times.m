clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v20d3_jump20_penalty1_zRatio100_twoTimes";

option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;
refLength=5;
refJump =2;
initialLength=5;
motionDecay=1/50;
thresFactor=5;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% first registration
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,option.zRatio]=readMeta(reader);

option.zRatio=100;

tRange=1:20:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength]);

option.motion=zeros([X,Y,Z,3]);
dat_ref=readOneFrame_double(reader,1,2);
option.mask_ref=getMask(dat_ref,thresFactor);

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
        option.mask_ref=getMask(dat_ref,thresFactor);
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotion_Wei_v20d3(dat_mov,dat_ref,smoothPenalty,option);
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
%     save(resPathName+"/motion_first_"+t+".mat","motion_current");
    toc;
end
%% save the first result
disp("save result (1)...");
cd(resPathName);

out1=reshape(dat_corrected1,X,Y,Z,1,length(tRange));
out2=reshape(dat_corrected2,X,Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'FirstCorrected.ome.tiff');
%% second registration

[~,~,~,~,~,option.zRatio]=readMeta(reader);

filePath2=resPathName + ...
    "/FirstCorrected.ome.tiff";

reader = bfGetReader(convertStringsToChars(filePath2));
omeMeta = reader.getMetadataStore();
Y = omeMeta.getPixelsSizeX(0).getValue(); 
X = omeMeta.getPixelsSizeY(0).getValue(); 
Z = omeMeta.getPixelsSizeZ(0).getValue(); 
T = omeMeta.getPixelsSizeT(0).getValue(); 

dat_corrected1=zeros([X,Y,Z,T],"uint16");
dat_corrected2=zeros([X,Y,Z,T],"uint16");

dat_ref=readOneFrame_double(reader,1,2);
option.motion=[];

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(tCnt+"/"+T);
    % read data
    disp("read data (2)...");
    dat_mov=readOneFrame_double(reader,tCnt,2);
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
    motion_current=getMotion_Wei_v20(dat_mov,dat_ref,smoothPenalty,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(readOneFrame_double(reader,tCnt,1),motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % save motion
    disp("save motion...");
%     save(resPathName+"/motion_second_"+t+".mat","motion_current");
    toc;
end

%% save the second result
disp("save result (2)...");
cd(resPathName);

reader = bfGetReader(convertStringsToChars(filePath));
out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'zRatio100_twoTimes.tiff');