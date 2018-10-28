function im = fractionalNoise3(im, w, octaves, step, persistence, lacunarity)
%
% creates and sum successive octaves of gaussian noise, each with higher
% frequency and lower amplitude (fractional Brownian motion). nomalize
% output within [0 1]
%
% input:
% - im: initial 3-dimensional array
% - w : grid size in pixels of the first noise octave (lowest spatial frequency)
% - octaves: number of noisy octaves with increasing spatial frequency to
%            be added
%
% optional:
% - lacunarity: frequency multiplier for each octave (usually set to 2 so
%               spatial frequency doubles each octave)
% - persistence: amplitude gain (usually set to 1/lacunarity)
%
% When lacunarity=2 and persistence=0.5 you get the 1/f noise
%
% Matteo Lisi, 2014
%

if nargin <= 4
    lacunarity = 2;
    persistence = 0.5;
end

[n, m, v] = size(im); a = 1;

for oct = 1:octaves

    rndim = -1 +2*rand(ceil(n/w),ceil(m/w),ceil(v/w));   % uniform [-1 1]

    [Xq,Yq,Zq] = meshgrid(linspace(1,size(rndim,2),m),linspace(1,size(rndim,1),n),linspace(1,step*size(rndim,3),v));
    [Xs,Ys,Zs] = meshgrid(1:size(rndim,2),1:size(rndim,1),linspace(1,step*size(rndim,3),size(rndim,3)));
    
    %d = ba_interp3(rndim,Xq,Yq,Zq, 'cubic'); % this is faster but need compiling the mex file
    d = interp3(Xs,Ys,Zs,rndim,Xq,Yq,Zq, 'cubic'); % not optimized

    im = im + a*d(1:n, 1:m, 1:v);
    a = a*persistence;
    w = w/lacunarity;
end
im = (im - min(min(min(im(:,:,:))))) ./ (max(max(max(im(:,:,:)))) - min(min(min(im(:,:,:)))));
