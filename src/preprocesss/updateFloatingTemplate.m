function dat_ref_float=updateFloatingTemplate(dat_ref_float,dat_ref_fixed,thresFactor,optionTemplate,smoothPenaltyTemplate)

optionTemplate.mask_mov=getMask(dat_ref_float,thresFactor);
[~,~,x_new,y_new,z_new]=getMotionHZR_Wei_v1(dat_ref_float,dat_ref_fixed,smoothPenaltyTemplate,optionTemplate);
dat_ref_float=correctMotion_Wei_v3(dat_ref_float,x_new,y_new,z_new);

end