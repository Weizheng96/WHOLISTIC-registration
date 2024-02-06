clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/work/public/Virginia Rutten/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/exp0/imag/" + ...
    "221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_7dpf002.nd2";

resPathName="/ssd2/Wei/221124_f338/221124_f338-230326-2Dv2_r5p1";

option.layer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;
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

tRange=45:55;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([round(X/2^option.layer),round(Y/2^option.layer),Z,2,initialLength],"single");

option.motion=[];
dat_ref=readOneFrame_single(reader,1,2);
option.mask_ref=getMask(dat_ref,thresFactor);

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov=readOneFrame_single(reader,t,2);
    option.mask_mov=getMask(dat_mov,thresFactor);
    toc;
    % get reference image
    disp("generate reference...");
    if tCnt>refLength*refJump && mod(tCnt,refJump)==1
        refRange=(tCnt-refLength*refJump):refJump:(tCnt-1);
        dat_ref=single(median(dat_corrected2(:,:,:,refRange),4));
        option.mask_ref=getMask(dat_ref,thresFactor);
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotion2D_Wei_v4(dat_mov,dat_ref,smoothPenalty,option);
    [dat_corrected1(:,:,:,tCnt),dat_corrected2(:,:,:,tCnt)]=...
        correctMotion2D_Wei_v2(readOneFrame_double(reader,t,1),dat_mov,motion_current);
    toc;
    % motion correction
    disp("initialize motion...");
    [motion_history,BestMotion]=updateMotionHistory_v3(motion_current,motion_history);
    option.motion=BestMotion;
    toc;
    % save motion
%     disp("save motion...");
%     save(resPathName+"/motion_first_"+t+".mat","motion_current");
%     toc;
end
%% save the first result
tic;
disp("save result (1)...");
cd(resPathName);
out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
toc
tic
bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');
toc
%%

disp("save result (2)...");
cd(resPathName);
tic
out1=reshape(dat_corrected1,X,Y,Z,1,length(tRange));
toc
tic
out2=reshape(dat_corrected2,X,Y,Z,1,length(tRange));
toc
tic
bfsave(cat(4,out1,out2), 'Corrected.ome.tiff');
toc