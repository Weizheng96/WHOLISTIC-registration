function [moX,moY]=readOneZsliceMotion(fileName,z)
load(fileName,"motion_current");
moX=motion_current(:,:,z,1);
moY=motion_current(:,:,z,2);
end