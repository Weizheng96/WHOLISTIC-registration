function im_texture=getHighFrequencyComponent(dat_ref,smFactor)

im_sm=imgaussfilt(dat_ref,smFactor);
im_texture=dat_ref-im_sm;

end