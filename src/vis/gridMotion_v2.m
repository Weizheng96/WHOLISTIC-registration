function gridMotion_v2(dat,motion_current,z,r)

[x,y,~,~]=size(motion_current);
xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;
moX=motion_current(xG,yG,z,1);
moY=motion_current(xG,yG,z,2);

[GridY,GridX] = meshgrid(yG,xG);

Unew=moX+GridX;
Vnew=moY+GridY;

gridMotion(dat(:,:,z),Unew,Vnew);

end