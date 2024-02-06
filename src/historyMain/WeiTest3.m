clear;clc;
% load("/work/Wei/Projects/WholeFishAnalyss/dat/opticalFlowTestData.mat","dat2_crop");

load("/work/public/Virginia Rutten/221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_8505_7dpf_hypoxia/mat data/dat.mat","dat2");
dat2=dat2(:,:,:,1:100);

save("221124_dat2","dat2","-v7.3");
dat_ref=double(dat2(:,:,:,1));
dat_corrected1=zeros(size(dat2),"uint16");
for t=1:65%size(dat2,4)
    tic;
    disp(t+"/"+size(dat2,4));
    dat_mov=double(dat2(:,:,:,t));
    phi_current=getMotion_Wei(dat_mov,dat_ref);
%     dat_corrected1(:,:,:,t)=correctMotion_Wei(dat_mov,phi_current);
%     dat_corrected2(:,:,:,t)=correctMotion_Wei(dat_mov,phi_current);
    toc;
end

vid1=(squeeze(double(dat2(:,:,7,:)))-100)/500;
vid2=(squeeze(double(dat_corrected(:,:,7,:)))-100)/500;
implay(cat(2,vid1,vid2))

z=5;
out=cat(2,squeeze(dat2(:,:,z,1:200)),squeeze(dat_corrected(:,:,z,1:200)));
tifwrite(out, "corrected_"+z+".tif");

% save("221124","dat_corrected","dat2","-v7.3");