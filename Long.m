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
%{
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
%}
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