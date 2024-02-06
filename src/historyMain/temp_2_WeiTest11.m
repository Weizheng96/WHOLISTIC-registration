clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%%
anaFilePath="/work/public/Virginia Rutten/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/anatomy/exp0/start/" + ...
    "221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_7dpf001_anat.nd2";
resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/221124_f338/ref";
%%

option.larer=3;
option.iter=10;
option.r=5;
smoothPenalty=10;
maskThres=400;

reader = bfGetReader(convertStringsToChars(anaFilePath));
dat_ana=readOneFrame_single(reader,1,2);
[~,~,Z,~,~,option.zRatio_ref]=readMeta(reader);

corrLst_next=zeros(1,Z-1);

for i=1:Z-1
    dat_mov=dat_ana(:,:,i);
    dat_ref=dat_ana(:,:,i+1);
    R = corrcoef(dat_mov(:),dat_ref(:));
    corrLst_next(i)=R(2,1);
end

corrLst_pre=[nan corrLst_next];
corrLst_next=[corrLst_next nan];

corrLst=max(corrLst_next,corrLst_pre,'omitnan');


y = medfilt1(corrLst,9);

diffLst=corrLst-y;diffLst(1)=0;diffLst(end)=0;
zThres=-2;
invalidIdx=find(diffLst<std(diffLst)*zThres);

dat_ana_corrected=dat_ana;
for i=invalidIdx
    dat_ana_corrected(:,:,i)=(dat_ana(:,:,i-1)+dat_ana(:,:,i+1))/2;
end

% implay(dat_ana_corrected/300)

dat_ana_corrected2=dat_ana_corrected;

padSZ=2;
for i=1+padSZ:Z-padSZ
    disp(i);
    dat_mov=dat_ana_corrected2(:,:,i);
    dat_ref=median(dat_ana_corrected(:,:,i-padSZ:i+padSZ),3);
    
    option.mask_ref=imdilate(abs(dat_ref)>maskThres,ones(3));
    option.mask_mov=imdilate(abs(dat_mov)>maskThres,ones(3));
    
    [motion_current,~]=getMotion2D_Wei_v1(dat_mov,dat_ref,smoothPenalty,option);
    dat_ana_corrected2(:,:,i)=correctMotion2D_Wei_v1(dat_mov,motion_current); 
end

% implay(dat_ana_corrected2/300)

%%
disp("save result (1)...");
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
cd(resPathName);
bfsave(dat_ana_corrected2, 'ref_ch2_corrected.ome.tiff');
