function [U,V]=opticalflow2d(ct1,ct2)


subplot(221)
imagesc(ct1);
subplot(222);
imagesc(ct2);
alpha=20;    
SZ=size(ct1);

ex1=(circshift(ct1,[0,-1])-circshift(ct1,[0,1]))/2;
ey1=(circshift(ct1,[-1,0])-circshift(ct1,[1,0]))/2;

U=zeros(SZ);
V=zeros(SZ);

for n=1:3
    alpha=alpha+20;
    
    ex2=(circshift(ct2,[0,-1])-circshift(ct2,[0,1]))/2;
    ey2=(circshift(ct2,[-1,0])-circshift(ct2,[1,0]))/2;
    ex=(ex1+ex2)/2;
    ey=(ey1+ey2)/2;
    et=ct2-ct1;
    u=zeros(size(ct1));
    v=u;
    uu=u;
    vv=v;
    u=uu-ex.*(ex.*uu+ey.*vv+et)./(alpha*alpha+ex.*ex+ey.*ey);
    v=vv-ey.*(ex.*uu+ey.*vv+et)./(alpha*alpha+ex.*ex+ey.*ey);    
    def1=zeros(size(ct1));
    for i=1:SZ(1)
        for j=1:SZ(2)
            ii=round(i+v(i,j));
            jj=round(j+u(i,j));
            if ii>0 && ii<SZ(1)+1 && jj>0 && jj<SZ(2)+1
                def1(i,j)=ct2(ii,jj);
            end
        end
    end
    U=round(u)+U;
    V=round(v)+V;
    ct2=def1;
    subplot(223);
    imagesc(et);
    subplot(224)
    imagesc(def1);
    title(n);
    pause(0.1);
end
