%%
clear;
clc;

%% Parameters
fs = 24e6/26/128; % sampling rate
fc = fs/2/pi; % central freq

%% Visualization
fid=fopen('record.snd','rb');
[a,n]=fread(fid,[1 inf],'int16');
fclose(fid);
a = a/65536; % normalization

t = (0:1:(n-1))/fs; % time axis
plot(t,a,'-','LineSmoothing','On');
axis([0,256/fs,-1.25*max(abs(a)),1.25*max(abs(a))]);
grid on;

%% Play it
amp = 16; % amplify
sound(amp*a, fs); % play the recording
