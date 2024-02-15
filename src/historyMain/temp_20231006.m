clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% file path
filePath="/work/public/Virginia Rutten/" + ...
    "221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/exp0/imag/" + ...
    "221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_7dpf002.nd2";

anaFilePath="/work/public/Virginia Rutten/" + ...
    "221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/anatomy/exp0/start/" + ...
    "221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_7dpf_anat001.nd2";

AnnoFilePath="/work/public/Virginia Rutten/" + ...
    "221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia_t23/exp0/annot/combined.tif";

resPathName="/work/public/Virginia Rutten/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/" + ...
    "f338_High2Low_r20_rp0d1_2023100606";
%% parameters
option.layer=3;
option.iter=100;
option.r=20;
smoothPenaltyTemplate=0.1;
thresFactor=5;
smFactor=50;
%% generate the folder
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% correct anatomic image (moving)
[dat_ana_corrected2,option.zRatio]=correctAnaFile(anaFilePath,resPathName); % saved as "ref_ch2_corrected.ome.tiff"
%% normalize anatomical
dat_mov=dat_ana_corrected2(1+298:end-298,:,:);
%% get valid z slice (template)
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,zRatio_vid]=readMeta(reader);
dat_ref=readOneFrame_single(reader,1,2);
option.zRatio_mov=zRatio_vid;
option.zRatio_ref=option.zRatio;
option.zLst=getZLst(dat_mov,dat_ref,option);
dat_ref_new=resizeMov_v2(dat_ref,size(dat_mov,3),option.zLst);
%% normalize ref and ref mask
option.mask_refPad=true(size(dat_mov));
option.mask_refPad(:,:,floor(option.zLst))=false;
option.mask_refPad(:,:,ceil(option.zLst))=false;
% dat_ref_norm=getHighFrequencyComponent(dat_ref_new,smFactor);
option.mask_ref=logical(option.mask_refPad+getMask(dat_ref_new,thresFactor));
%% normalize mov and mov mask
% muRef=mean(dat_ref,'all');
% sigmaRef=std(dat_ref,0,'all');
% dat_mov_norm=getHighFrequencyComponent(dat_mov,smFactor);
% dat_mov_norm=meanStdNormalization(dat_mov,muRef,sigmaRef);

dat_mov_selected=dat_mov(:,:,round(option.zLst));
mov=sort(dat_mov_selected(:));
ref=sort(dat_ref(:));
step=1000;
testx=mov(1:step:end);
testy=ref(1:step:end);
X=[ones(size(testx)) testx];
W=X\testy;
dat_mov_norm=dat_mov*W(2)+W(1);

option.mask_mov=getMask(dat_mov_norm,thresFactor);
option.mask_movPad=false(size(dat_mov));
%%
[~,~,x_new,y_new,z_new]=getMotion_Wei_v24d3(dat_mov_norm,dat_ref_new,smoothPenaltyTemplate,option);
%%
temp=correctMotion_Wei_v3(dat_mov,x_new,y_new,z_new);
dat_out=temp(:,:,round(option.zLst));
tifwrite(uint16(dat_out),fullfile(resPathName,"data_corrected.tif"))
dat_anno=tifread(AnnoFilePath);
dat_anno=dat_anno(1+298:end-298,:,:);
temp=correctMotion_Wei_v3_nearest(dat_anno,x_new,y_new,z_new);
labels=temp(:,:,round(option.zLst));
tifwrite(uint8(labels),fullfile(resPathName,"label_corrected.tif"))

out_dat=gray2RGB_HD(max(min(dat_ref/400,1),0));
out_newId=label2RGB_HD(labels);
out=out_dat*0.8+out_newId*0.5;
tifwrite(double(out),fullfile(resPathName,"label_corrected_vis.tif"))

out_newId=label2RGB_HD(cat(2,dat_anno(:,:,round(option.zLst)),labels));
out2=cat(2,out_dat,out_dat)*0.8+out_newId*0.5;
tifwrite(double(out2),fullfile(resPathName,"raw_corrected_vis.tif"))

