function mask=getMask(dat_mov,thresFactor)

% dat_mov=gpuArray(dat_mov);
dat_mov=single(dat_mov);
mu=mean(dat_mov(:));
sigma=std(dat_mov(:));

mask=abs((dat_mov-mu)/sigma)>thresFactor;
% mask = imfill(mask,"holes");
mask=imopen(mask,ones(3));
mask=imdilate(mask,ones(3));

% mask=gather(mask);

end