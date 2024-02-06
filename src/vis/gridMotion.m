function gridMotion(dat,Unew,Vnew)

hold off;
imshow(dat);
hold on;
for ix=1:size(Vnew,1)
    plot(Vnew(ix,:),Unew(ix,:),'r')
end
for iy=1:size(Vnew,2)
    plot(Vnew(:,iy),Unew(:,iy),'r')
end


end