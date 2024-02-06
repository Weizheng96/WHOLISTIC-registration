function dat_ref_float=updateFloatingTemplate_v3(dat_ref_float,dat_ref_fixed,thresFactor,optionTemplate,smoothPenaltyTemplate)

dat_mov=resizeMov_v2(dat_ref_float,size(dat_ref_fixed,3),optionTemplate.zLst);
dat_mov_norm=getHighFrequencyComponent(dat_mov,optionTemplate.smFactor);
dat_mov_norm=meanStdNormalization(dat_mov_norm,optionTemplate.muRef,optionTemplate.sigmaRef);
optionTemplate.mask_mov=getMask(dat_mov_norm,thresFactor);

% motion correction
disp("estimate template motion...");
[~,~,x_new,y_new,z_new]=getMotion_Wei_v24d3(dat_mov_norm,dat_ref_fixed,smoothPenaltyTemplate,optionTemplate);

disp("correct template motion...");
temp=correctMotion_Wei_v3(dat_mov,x_new,y_new,z_new);
dat_ref_float=temp(:,:,optionTemplate.zLst);


end