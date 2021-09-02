pat = 'WAV/';
files = dir([pat,'*.wav']);

n = 21;
filename = files(n).name(1:end-4);
data = readtable(['TXT/',filename ,'.txt']);
Tini = data.Var1;
Tend = data.Var2;
labels = data.Var3;

[audio, fs] = audioread([pat,files(n).name]);

for i=1:1:length(labels)
audio1 = audio(floor(Tini(i)*fs+1):floor(Tend(i)*fs+1));
audiowrite([filename,'_',char(labels(i)),'_',int2str(i),'.wav'],audio1, fs)
end