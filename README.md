# FISH CLASSIFICATION
Summary report of summer research program UD


## Exploring DataSets

The datasets are explored using signal processing and matlab. 

Importing the audio data and applying the Fourier transform is implement in the code Data.m.

```Matlab
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
```

The first step is explore the whole data, plotting all the days spectrograms with high time resolution, using LongSpectrogram.m code


```Matlab
clear all
tic
%% Choosing channel 
cha = 'C2';

%% Loading channel
data_1 = load(['OldData/DataEvery20',cha,'/Data_1_96_SDXC1']).data;
data_2 = load(['OldData/DataEvery20',cha,'/Data_1_33_SDXC1']).data;
data_3 = load(['OldData/DataEvery20',cha,'/Data_1_138_SDXC2']).data;
data_4 = load(['OldData/DataEvery20',cha,'/Data_1_139_SDXC3']).data;
data_5 = load(['OldData/DataEvery20',cha,'/Data_1_27_SDXC4']).data;

meta_data_1 = load(['OldData/DataEvery20',cha,'/MetaData_1_96_SDXC1']).meta_data;
meta_data_2 = load(['OldData/DataEvery20',cha,'/MetaData_1_33_SDXC1']).meta_data;
meta_data_3 = load(['OldData/DataEvery20',cha,'/MetaData_1_138_SDXC2']).meta_data;
meta_data_4 = load(['OldData/DataEvery20',cha,'/MetaData_1_139_SDXC3']).meta_data;
meta_data_5 = load(['OldData/DataEvery20',cha,'/MetaData_1_27_SDXC4']).meta_data;

%% Channel 2
% ch = '-C2';
% data_11 = load(['OldData/DataEvery20-C1',ch,'/Data_1_96_SDXC1']).data;
% data_21 = load(['OldData/DataEvery20-C1',ch,'/Data_1_33_SDXC1']).data;
% data_31 = load(['OldData/DataEvery20-C1',ch,'/Data_1_138_SDXC2']).data;
% data_41 = load(['OldData/DataEvery20-C1',ch,'/Data_1_139_SDXC3']).data;
% data_51 = load(['OldData/DataEvery20-C1',ch,'/Data_1_27_SDXC4']).data;

%% Combining data
data = [data_1,data_2,data_3,data_4,data_5];
meta_data = [meta_data_1,meta_data_2,meta_data_3,meta_data_4,meta_data_5];
toc
%DATA = data(i).P;%-data1(i).P;

hold on
for i=1:1:length(data) %length(combined)
    %if length(data(i).T) ~= 0
        Tini = datenum([meta_data(i).date_ini,' ',meta_data(i).time_ini(1:end-4)]);
        imagesc(data(i).T/(3600*24)+Tini, data(i).F, 10*log10(abs(data(i).P)))  
    %end
end

Tin = datenum([meta_data(1).date_ini,' ',meta_data(1).time_ini(1:end-4)]);
Tend = data(i).T(end)/(3600*24)+Tini;

%% Make days plots
%% --------- CODE HERE -------------

%% Plot whole spectrum
title('Whole Channel 2 - 1khz');
xtickangle(0)
ylim([0 1000]);
c = colorbar('eastoutside');
caxis([-80 -10]);
c.Label.String = 'Power/Frequency (dB/Hz)';
colormap jet;
xlabel('Time (days)');
ylabel('Frequency (Hz)');
set(gcf,'position',[0 0 1800 750])
set(gca,'FontSize',25)

hold off
%xlim([Tin Tend]);

datetick()%'keeplimits')
xlim([Tin Tend]);

toc
%saveas(gcf,'All-C2-1k.png')
```

To plot daily spectrograms use the code below and put it in the CODE HERE line

```Matlab
for k = 18:1:30
    Tin = datenum([int2str(k),'-July-2013 00:00:00']);
    Tend = datenum([int2str(k+1),'-July-2013 00:00:00']);
    title(['July ',int2str(k),', 2013 - C1 - 1khz'])

    ticks = Tin:60/24/60:Tend;
    set(gca,'XTick',ticks);
    datetick('x','HH','keepticks');
    xlabel('Time (h)')
    xtickangle(0)
    saveas(gcf,['July',int2str(k),'-C1-1khz.png'])
end
```


### Fysh Catalog 


### Delaware Bay


##


## Data Augmentation

## Claassification

Homepage: https://saguileran.github.io/FishClassification/
