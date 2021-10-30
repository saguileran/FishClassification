# FISH CLASSIFICATION
Summary report of summer research program UD


## Exploring DataSets

The datasets are explored using signal processing and matlab. 

Importing the audio data and applying the Fourier transform is implement in the code Data.m.

'''
clear all

pat = '/data/badiey/fromENGR/DATA/2_RAW/14_FISH_SOUNDS/Raw_Recorded_Data/SDXC1/Converted Data_1/';
files = dir([pat,'*.wav']);
names = extractfield(files,'name')';
N = length(files);

fin =  1;
fend = length(files);
i = fin;

for n = 1:1:fend-fin+1
        meta_data(n).name = files(i).name;
        meta_data(n).folder = files(i).folder;

        date =  char(datetime(files(i).name(1:18),'InputFormat','yyyyMMdd_HHmmss_SSS','Format','d-MMMM-yyyy HH:mm:ss:SSS'));
        meta_data(n).date_ini = date(1:12);
        meta_data(n).time_ini = date(14:end);

        [audio,fs] = audioread([pat,files(n).name]);
        audio = audio(:,2);

        date = char(datetime(date,'InputFormat','d-MMMM-yyyy HH:mm:ss:SSS','Format','d-MMMM-yyyy HH:mm:ss:SSS') + seconds(length(audio)/fs));
        meta_data(n).date_end = date(1:12);
        meta_data(n).time_end = date(14:end);

        meta_data(n).duration = length(audio)/fs;

        meta_data(n).fs = fs;
        meta_data(n).samples = length(audio);  

        fs_new = 10000;
        audio = resample(audio,fs_new,fs);

        overlap_perc = 0.8;
        nff = fs_new;
        time_windows = nff/fs_new;
        ntw = floor(time_windows*fs_new);   % Number of points for time windows
        nov = floor(ntw*overlap_perc);  % Number of points for overlap

        [~,F,T,P] = spectrogram(audio, hamming(ntw), nov, nff, fs_new, 'yaxis');

        if meta_data(n).duration < 80
            dt = floor(5 / (T(2)-T(1)))-1;
        else
            dt = floor(20 / (T(2)-T(1)));
        end        

        Pnew = zeros(length(F),floor(length(T)/dt));
        Tnew = zeros(1,floor(length(T)/dt));
        p = 1;        

        for j = 1:dt:length(T)-dt
            Tnew(p)     = mean(T(j:j+dt));
            Pnew(:,p)   = mean(P(:,j:j+dt),2);
            p=p+1;
        end

        data(n).T = Tnew;
        data(n).F = F;
        data(n).P = single(Pnew);

        meta_data(n).fs_new = 10000;
        meta_data(n).samples_new = length(audio);

        i = i +1;
end

save(['Data_',int2str(fin),'_',int2str(fend),'_SDXC1_2.mat'],'data','-v7.3')
save(['MetaData_',int2str(fin),'_',int2str(fend),'_SDXC1_2.mat'],'meta_data','-v7.3')

'''

The first step is explore the whole data, plotting all the days spectrograms with high time resolution, using LongSpectrogram.m code

### Fysh Catalog 


### Delaware Bay


##


## Data Augmentation

## Claassification

Homepage: https://saguileran.github.io/FishClassification/
