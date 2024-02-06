function factor=getSmPnltNormFctr(dat_ref,option)

Ix=(dat_ref(3:end,:,:)-dat_ref(1:end-2,:,:))/2;
Iy=(dat_ref(:,3:end,:)-dat_ref(:,1:end-2,:))/2;

factor=(mean(Ix(~option.mask_ref(2:end-1,:,:)).^2)+mean(Iy(~option.mask_ref(:,2:end-1,:)).^2))/2;

end