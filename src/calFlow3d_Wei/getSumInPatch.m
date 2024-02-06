function dat_out=getSumInPatch(dat,r,rz,xG,yG,zG,x,y,z)

% dat=Ix.^2;
dat_out=gpuArray(zeros(length(xG),length(yG),length(zG),'single'));

for xCnt=-r:r
    xGb=rangeConstrain(xG+xCnt,1,x);
    for yCnt=-r:r
        yGb=rangeConstrain(yG+yCnt,1,y);
        for zCnt=-rz:rz
            zGb=rangeConstrain(zG+zCnt,1,z);
            dat_out=dat_out+dat(xGb,yGb,zGb);
        end
    end
end


end