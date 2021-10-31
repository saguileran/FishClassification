clear all
close all

%%% Written by: Justin Eickmeier
%%% Updated: August 29, 2018
%%% jeickmei@udel.edu

%%% This program plots the amplitude,spectrogram and power spectral density 
%%% of audio files in a variety of formats with a timeline
%%% The final output is an .AVI movie file combining both audio and video
tic
pat = 'C:\Users\sanro\OneDrive\Documents\';
files = dir([pat,'*.wav']);
fname = files(1).name
%%% Frames Per Second
FPS = 1; 

% % sampling rate of the data is fs, amp is the audio data
[amp,fs] = audioread([pat,fname]);

part_duration = 10; %minutes
samples_part = (part_duration+0.05)*60*fs; %samples
file_duration = length(amp)/fs/60;  %minutes

subfiles_no = floor(file_duration /part_duration);
i = 0;
amp = amp(samples_part*i+1:samples_part*(i+1)+1,1);
%amp = amp(1:floor(length(amp)/2),1:2);


total_rec_time = length(amp)/fs; % length of recording

overlap_perc = 0.9;
nff          = fs;
ntw          = floor(nff);   % Number of points for time windows
nov          = floor(ntw*overlap_perc);  % Number of points for overlap

Clim = [-80 -10];
%Clim = [-140 -50];
ymax = input('Enter max frequency: ');

% display spectrogram of entire sample
%[y,f,t,p] = spectrogram(amp(:,1),1024*2,1800,2048,fs);
[y,f,t,p] = spectrogram(amp(:,1), hamming(ntw), nov, nff, fs, 'yaxis');

Tini = datenum(datetime(fname(1:18),'InputFormat','yyyyMMdd_HHmmss_SSS','Format','d-MMMM-yyyy HH:mm:ss:SSS'))-datenum(seconds(1));
Tend = datenum(Tini + seconds(length(amp)/fs));

T = t/(3600*24)+Tini;

figure 
imagesc(datenum(T),f,10*log10(abs(p)));
colormap('jet')
set(gca,'YDir','normal','fontsize',24,'Clim', Clim, 'Ylim', [0 ymax]); 
set(gcf, 'Position', get(0,'Screensize')); 
title('Click to Select Start Time (Max Frequency) and End Time (Min Frequency)','fontsize',20);
xtickangle(90)
xlim([datenum(T(1)) datenum(T(end)+seconds(0.1))])
datetick('keeplimits');%'x','mm:ss', 'keepticks');
xlabel('Time (hh:mm)','fontsize',20);
ylabel('Frequency (Hz)','fontsize',20);
h = colorbar;
set(h,'Fontsize',20)
ylabel(h,'dB (Relative)')

% prompt user for start / end time and max / min frequency 
T_sig_1 = ginput(2);%
T_sig_1(:,1) = (T_sig_1(:,1) -Tini)*3600*24;

max_freq = T_sig_1(1,2);
min_freq = T_sig_1(2,2);


data_1  = amp(round(T_sig_1(1,1)*fs):round(T_sig_1(2,1)*fs),1);

%%%% Filtering audio file based on selected max/min frequencies 
%%%% Low-pass filter
fbe = [0  round((max_freq/(fs/2)*100))/100 (round((max_freq/(fs/2)*100))/100+0.05) 1]; 
damps = [1 1 0 0]; 
fl = 100; 
b = firpm(fl,fbe,damps);    
filt_out = filter(b,1,data_1); 


% %%% High-pass filter
fbe = [0  round((min_freq/(fs/2)*100))/100 (round((min_freq/(fs/2)*100))/100+0.05) 1]; 
damps = [0 0 1 1]; 
fl = 10;
% impulse response of LPF
b = firpm(fl,fbe,damps);    
%%freqz(b,1)

filt_out1 = filter(b,1,filt_out); %final files


nff          = 4*fs;
ntw          = floor(nff);   % Number of points for time windows
nov          = floor(ntw*overlap_perc);  % Number of points for overlap

[y1,f1,t1,p1] = spectrogram(filt_out1, hamming(ntw), nov, nff, fs, 'yaxis');
%t = (t-datenum(Tini))*3600*24;

%Tini = datenum(datetime(fname(1:18),'InputFormat','yyyyMMdd_HHmmss_SSS','Format','d-MMMM-yyyy HH:mm:ss:SSS'));
%Tend = datenum(Tini + seconds(length(filt_out1)/fs));

len         = min(length(filt_out1));  
frame_count = floor((len/fs)*FPS);
t           = (0:(len-1))./fs;

time_start = (T_sig_1(1,1)/(3600*24) +Tini)-datenum(seconds(1));
time_end   = (T_sig_1(2,1)/(3600*24) +Tini)+datenum(seconds(1));

%%%% Creating Video Writer Object
time_start_str = char(datetime(time_start,'ConvertFrom','datenum'));
time_end_str = char(datetime(time_end,'ConvertFrom','datenum'));
time_start_str = [time_start_str(13:14),time_start_str(16:17),time_start_str(19:20)];
time_end_str = [time_end_str(13:14),time_end_str(16:17),time_end_str(19:20)];
title_1  = ['Video_from_',time_start_str,'s_to_',time_end_str,'s.avi'];
title_1a = ['Audio_from_',time_start_str,'s_to_',time_end_str,'s'];
title_1b = ['Video_from_',time_start_str,'s_to_',time_end_str,'s_final.avi'];
title_2  = [' -  From ',time_start_str,'s to ',time_end_str,'s'];
title_3  = [time_start_str,'s_to_',time_end_str,'_s'];

file_spl = strsplit(fname,'.');
holder   = char(file_spl(1));
folder_n = [holder,'_',title_3];

%%%% Creating output directory 
mkdir('Bird_songs2',folder_n)
make_folder = ['Bird_songs2','\',folder_n];
title_4     = [make_folder,'\',title_1a];
title_4a    = [make_folder,'\',title_1];

writerObj           = VideoWriter(title_4a);
writerObj.FrameRate = FPS;
writerObj.Quality   = 20;
open(writerObj);                                              

%%% Time vectors                                              
time      = 0:1/fs:length(filt_out1)/fs; % Full length time vector 
time      = time/(3600*24) + time_start;
time_step = time_start:datenum(seconds(1/FPS)):time_end;
% time_start:1/FPS:time_end;%0:1/FPS:(length(filt_out1)/fs);

%%% length minus 1 to fit size oxf audio data
time_plot = (time(1:(length(time)-1)))'; 

% player=audioplayer(filt_out1, fs);
% play(player);

% write .wav file for movie
audiowrite([title_4,'.wav'],filt_out1,fs)       

%Tend = datenum(Tini + seconds(time_plot(end)));
%Tini = Tini + seconds(time_plot(1));    

%time_plot = time_plot/(3600*24)+Tini;
%time_step = datenum(time_step/(3600*24)+Tini);

%%% Frame by frame movie generation 
figure
tit = char(datetime(fname(1:end-8),'InputFormat','yyyyMMdd_HHmmss','Format','d-MMMM-yyyy HH:mm:ss'));
sgtitle([tit,'  ',title_2],'fontsize',26);
h1 = subplot(3,8,[1 5]);
plot(time_plot,filt_out1/(max(filt_out1)))
set(gca,'Layer','top','FontSize',24,'Ylim',[-1.0 1.0],...%'Xlim',[time_start time_end],...
    'XMinorTick','on','YMinorTick','on')
set(gcf, 'Position', get(0,'Screensize'));
set(gcf,'color','w');
xtickangle(0)
datetick()%'x','mm:ss', 'keepticks');
xlim([datenum(time_plot(1)) datenum(time_plot(end))])
ylabel('Amp.(Normalized)','fontsize',20);

h2 = subplot(3,8,[9 21]);
imagesc(time_plot',f1,10*log10(abs(p1)));
set(gca,'YDir','normal','Ylim',[min_freq max_freq],'Clim', [-80 -50],...%'Xlim',[time_start time_end]
    'fontsize',24); 
%a = input('Enter min Power: ');
%b = input('Enter max Power: ');
%caxis([a b])
set(gcf, 'Position', get(0,'Screensize')); 
xlabel('Time (min:sec)','fontsize',20);
ylabel('Frequency (Hz)','fontsize',20);
h = colorbar;

datetick()%'x','mm:ss', 'keepticks');
xlim([datenum(time_plot(1)) datenum(time_plot(end))])
colormap('jet')
set(h,'Position',[0.610 0.102 0.02 0.483],'Fontsize',20);
%set(h.XLabel,{'String','Rotation','Position'},{'dB',0,[0.5 -26.01]})
set(h.XLabel,{'String','Rotation','Position'},{'Power/Frequency (dB/Hz)',90,[2.5 -60.101]})


for i=1:frame_count
dat  = char(datetime(time_step(i),'ConvertFrom','datenum'));
h1.Title.String = [dat(13:end),' s'];
o  = line(h1,[time_step(i) time_step(i)],[-1 1],'color','black','Linewidth',1.5);
o2 = line(h2,[time_step(i) time_step(i)],[0 48000],'color','black','Linewidth',1.5);

N    = length(filt_out1(((fs/FPS)*(i-1)+1):((fs/FPS)*(i))));
xdft = fft(filt_out1(((fs/FPS)*(i-1)+1):((fs/FPS)*(i))));
xdft = xdft(1:N/2+1);
psdx = (1/(fs*N)) * abs(xdft).^2; 
psdx(2:end-1) = (2*psdx(2:end-1));
freq = (0:fs/length(filt_out1(((fs/FPS)*(i-1)+1):((fs/FPS)*(i)))):fs/2);

subplot(3,8,[7 24])
yyaxis left
set(gca,'yticklabel',{[]})
yyaxis right
ax = gca;
ax.YAxis(1).Color = 'k';
ax.YAxis(2).Color = 'k';
plot(10*log10(psdx),freq,'-o')

if i==1
psdxmin = min(10*log10(psdx));
psdxmax = max(10*log10(psdx));
end
set(gca,'Ylim',[min_freq max_freq],'Xlim',[psdxmin-10 psdxmax+10], 'Yminortick','on','fontsize',24);
grid on
title('Power Spectral Density','fontsize',20)
label_h = ylabel('Frequency (Hz)','fontsize',21);
label_h.Position(1) = 2;
xlabel('Power/Frequency (dB/Hz)','fontsize',20)
frame = getframe(gcf);
writeVideo(writerObj,frame);

% close gcf
delete(o);  delete(o2);
end
close(writerObj);
close(gcf)

cd(['Bird_songs2/',folder_n])
format = 'avi';

%%% Combining audio and video files together
videoFReader = vision.VideoFileReader(title_4a);
videoFWriter = vision.VideoFileWriter(title_1b,'FileFormat',format,'FrameRate'...
                            ,videoFReader.info.VideoFrameRate,'AudioInputPort', true);

[y_a,Fs]   = audioread([title_1a,'.wav']);
time_r     = length(y_a)/(Fs/FPS);
time_floor = floor(time_r);

for i=1:frame_count
audio      = y_a(((Fs/FPS)*(i-1)+1):((Fs/FPS)*(i)),1);
videoFrame = step(videoFReader);
step(videoFWriter, videoFrame, audio);
end

%%% finishes movie 
release(videoFReader);
release(videoFWriter);

toc