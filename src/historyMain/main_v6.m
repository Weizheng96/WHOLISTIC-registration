clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));


filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";


dat_corrected1=zeros(size(dat),"uint16");
dat_corrected2=dat_corrected1;

smoothPenalty=1;
for t=1:size(dat,4)
    tic;
    disp(t+"/"+size(dat,4));
    dat_mov=double(dat(:,:,:,t));
    phi_current=getMotion_Wei_v6(dat_mov,dat_ref,smoothPenalty);
    dat_corrected1(:,:,:,t)=correctMotion_Wei(double(dat1(:,:,:,t)),phi_current);
    dat_corrected2(:,:,:,t)=correctMotion_Wei(dat_mov,phi_current);
    toc;
end
%%
pathname="/work/Wei/Projects/WholeFishAnalyss/dat/230120_v6_allFrames";
if ~exist(pathname,"dir")
    mkdir(pathname);
end
cd(pathname);

for z=1:size(dat,3)
    out=cat(2,squeeze(dat1(:,:,z,:)),squeeze(dat_corrected1(:,:,z,:)));
    tifwrite(out, "corrected_ch1_"+z+".tif");
end

for z=1:size(dat,3)
    out=cat(2,squeeze(dat(:,:,z,:)),squeeze(dat_corrected2(:,:,z,:)));
    tifwrite(out, "corrected_ch2_"+z+".tif");
end

%%
% implay(double(squeeze(dat_corrected2(:,:,4,:)))/400)
save("dat_corrected1.mat","dat_corrected1","-v7.3");
save("dat_corrected2.mat","dat_corrected2","-v7.3");
