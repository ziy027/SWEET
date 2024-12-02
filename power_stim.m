function [mean_dBLow]= power_stim(data,stim_start,stim_off,opts)
% General parameters 
fs = data.srate;
params = struct('tapers', [3,5], 'Fs', fs,'trialave',1); movingwin = [2 .5];
if strcmp(opts,'on')
    E_stim = stim_start;
    win = [0 mean(stim_off-stim_start)];
else
    E_stim = stim_off(1:end-1);
    win = [0 -mean(stim_start-stim_off)];
end
for i=1:size(data,1)
    [Sa,ta,fa]=mtspecgramtrigc(data(i,:),E_stim,win,movingwin,params);
    freqR = [0 2];
    freqIndex = fa < freqR(2) & fa > freqR(1);
    if ~isempty(freqIndex)
        pxxLow = Sa(freqIndex);
        fLow = fa(freqIndex);
    end
    dBLow(i,:) = pow2db(pxxLow);
    mean_dBLow(i) = mean(dBLow(i,:));
end
end