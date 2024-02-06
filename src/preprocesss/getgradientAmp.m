function gradientAmp=getgradientAmp(dat_ref)

gradientAmp=zeros(size(dat_ref));

Ix=(dat_ref(3:end,2:end-1,:)-dat_ref(1:end-2,2:end-1,:))/2;
Iy=(dat_ref(2:end-1,3:end,:)-dat_ref(2:end-1,1:end-2,:))/2;
gradientAmp(2:end-1,2:end-1,:)=sqrt(Ix.^2+Iy.^2);

end