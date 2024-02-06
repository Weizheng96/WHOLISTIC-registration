function [moX,moY]=readOneZsliceGridMotion(fileName,z,r)
load(fileName,"motion_current");
[x,y,~,~]=size(motion_current);
xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;
moX=motion_current(xG,yG,z,1);
moY=motion_current(xG,yG,z,2);
end