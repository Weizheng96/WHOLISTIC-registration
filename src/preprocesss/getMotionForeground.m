function FG=getMotionForeground(templateOrg,z,DilateSZ)
gradientAmpOrg=getgradientAmp(templateOrg);
temp=imgaussfilt(gradientAmpOrg,5);

% z=2;
mu_raw=median(temp,'all');
sigma_raw=std(temp,[],'all');

upThres=mu_raw+z*sigma_raw;lowThres=mu_raw-z*sigma_raw;
temp_2=temp(:);
temp_2(temp_2>upThres)=[];temp_2(temp_2<lowThres)=[];

mu=median(temp_2);
% sigma=std(temp_2);

FG_raw=temp>mu;
FG=imdilate(FG_raw,strel('disk',DilateSZ));
% FG=imdilate(FG_raw,strel('disk',20));

end
% 
% implay(FG_raw)
% implay(FG)
% implay(templateOrg/300)