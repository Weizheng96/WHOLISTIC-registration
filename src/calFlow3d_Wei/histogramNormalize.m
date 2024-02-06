function dat_mov_normalized=histogramNormalize(dat_mov,IntOrdRef)

% IntOrdRef=sort(dat_ref(:));

[~,I]=sort(dat_mov(:));
dat_mov_normalized=dat_mov(:);
dat_mov_normalized(I)=IntOrdRef;
dat_mov_normalized = reshape(dat_mov_normalized, size(dat_mov));
% implay(dat_mov_normalized/300)

end