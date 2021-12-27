%%
clear;
clc;
clf;

%% Read Audio Data
[W Fs Nb] = wavread('sss.wav', 'native');

t = (0:length(W)-1)/Fs;
plot(t, W, 'LineSmooth', 'On');
axis([0 (length(W)-1)/Fs -6000 6000]);
grid on;

%% Rectification
Y = int32(abs(W));

subplot(2,1,1);
plot(t,Y,'.','LineSmoothing','On','MarkerSize',1);
grid on;
axis([0, (length(W)-1)/Fs, -6000, 6000]);

%% Envelope detection
linear_envelope_detection_thresh = 64;
for i=1:length(Y)
    if i==1
        prev=0;
    else
        prev=Y(i-1);
    end

    Y(i) = floor(mean([prev,Y(i)]));

    if Y(i)>prev+linear_envelope_detection_thresh
        Y(i) = prev+linear_envelope_detection_thresh;
    elseif Y(i)<prev-linear_envelope_detection_thresh
        Y(i) = prev-linear_envelope_detection_thresh;
    end
end

hold on;
plot(t,Y,'r.','LineSmoothing','On','MarkerSize',1);
hold off;
title('Envelope detection');

%% Accumulation
Nacc = 103;

for i=1:floor(length(Y)/Nacc)
    Y(i) = sum(Y((i*Nacc-Nacc+1):(i*Nacc)));
    t(i) = t(i*Nacc-Nacc+1);
end

Y = Y(1:floor(length(Y)/Nacc));
t = t(1:floor(length(t)/Nacc));

subplot(2,1,2);
plot(t,Y,'LineSmoothing','On');
axis([0, (length(W)-1)/Fs, -10000, 80000]);
grid on;

%% Decode
thresh = 250*103;

hold on;
plot([0, (length(W)-1)/Fs],[thresh, thresh], 'g--','LineSmoothing','On');
hold off;
title('Decisioned');

Y = 2*(Y>thresh).*thresh;

i=0;
while i<length(Y)
    i=i+1;
    if Y(i)<thresh, continue; end
    sum = 0;
    for d=1:6
        i=i+1;
        sum=sum+(Y(i)<thresh);
        if sum>3, break; end
    end
    if sum>3, continue; end
    
    byte = 0;
    for bit=7:-1:0
        sum = 0;
        for d=0:6
            i=i+1;
            sum=sum+(Y(i)>thresh);
        end
        if sum>3, byte = byte+2^bit; end
    end
    fprintf('%c', byte);
    
    sum = 0;
    for d=0:6
        i=i+1;
        sum=sum+(Y(i)>thresh);
        if sum>3, break; end
    end
    if sum>3, continue; end
end
fprintf('\n');
