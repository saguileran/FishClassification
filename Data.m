clear all

%% Path file and Wav names
pat = '/data/badiey/fromENGR/DATA/2_RAW/14_FISH_SOUNDS/Raw_Recorded_Data/SDXC1/Converted Data_1/';
files = dir([pat,'*.wav']);
names = extractfield(files,'name')';
N = length(files);

%% Choosing files
fin =  1;
fend = length(files);
i = fin;

%tic;
% n index for data structure, i index of files
for n = 1:1:fend-fin+1
    %if n~=18   %The file 18 has an error
        n
        %% File and name folder
        meta_data(n).name = files(i).name;
        meta_data(n).folder = files(i).folder;

        %% Time and inital date
        date =  char(datetime(files(i).name(1:18),'InputFormat','yyyyMMdd_HHmmss_SSS','Format','d-MMMM-yyyy HH:mm:ss:SSS'));
        meta_data(n).date_ini = date(1:12);
        meta_data(n).time_ini = date(14:end);

        %% Reading wave filea 
        [audio,fs] = audioread([pat,files(n).name]);
        audio = audio(:,2);
        
        %% Time and end date
        date = char(datetime(date,'InputFormat','d-MMMM-yyyy HH:mm:ss:SSS','Format','d-MMMM-yyyy HH:mm:ss:SSS') + seconds(length(audio)/fs));
        meta_data(n).date_end = date(1:12);
        meta_data(n).time_end = date(14:end);

        meta_data(n).duration = length(audio)/fs;

        %% Sample rate and number of samples
        meta_data(n).fs = fs;
        meta_data(n).samples = length(audio);  

        %% Resamping
        fs_new = 10000;
        audio = resample(audio,fs_new,fs);

        %% FFT and spectrogram parameter
        overlap_perc = 0.8;
        nff = fs_new;
        time_windows = nff/fs_new;
        ntw = floor(time_windows*fs_new);   % Number of points for time windows
        nov = floor(ntw*overlap_perc);  % Number of points for overlap

         %% Time, Frequencies, and Power arrays  
        [~,F,T,P] = spectrogram(audio, hamming(ntw), nov, nff, fs_new, 'yaxis');
        
        % Samples step for short audios
        if meta_data(n).duration < 80
            dt = floor(5 / (T(2)-T(1)))-1;
        else
            dt = floor(20 / (T(2)-T(1)));
        end        
        %% Taking averages
        Pnew = zeros(length(F),floor(length(T)/dt));
        Tnew = zeros(1,floor(length(T)/dt));
        p = 1;        

        for j = 1:dt:length(T)-dt
            Tnew(p)     = mean(T(j:j+dt));
            Pnew(:,p)   = mean(P(:,j:j+dt),2);
            p=p+1;
        end

        % Saving spectrogram variables in data
        data(n).T = Tnew;
        data(n).F = F;
        data(n).P = single(Pnew);
        %data(n).audio = audio;
        
        %% Fs and Length of reesampling
        meta_data(n).fs_new = 10000;
        meta_data(n).samples_new = length(audio);

        i = i +1;
    %end
end
toc;

tic;
%% Saving structure as mat
save(['Data_',int2str(fin),'_',int2str(fend),'_SDXC1_2.mat'],'data','-v7.3')
%writetable(struct2table(meta_data), ['MetaData_',int2str(fin),'_',int2str(fend),'.csv'])
save(['MetaData_',int2str(fin),'_',int2str(fend),'_SDXC1_2.mat'],'meta_data','-v7.3')
toc;