%%
clear;
clc;
clf;

vldt = @(v) assert(abs(v) < 32768);

%% Parameters
fs = 24e6/26/128; % sampling rate
fc = fs/2/pi; % central freq

t = 0:1/fs:1; % time axis

%% Based-band signal
BB = (t>1/3).*(t<2/3);

subplot(4,2,1);
plot(t,BB,'LineSmoothing','On');
grid on;
axis([0, 1, -0.5, 1.5]);
title('1.Base band signal');

%% Generate S16.10 Fixed Pointed Signal
A = 0.5;
X = A*cos(2*pi*fc*t).*BB;

subplot(4,2,3);
plot(t,X,'LineSmoothing','On');
grid on;
axis([0, 1, -1, 1]);
title('2.Audio Signal');

%% Add Noise
SNR=0;
X = awgn(X, -db(0.5*A^2)+SNR);
X = round(X*2048);

subplot(4,2,5);
plot(t,X,'LineSmoothing','On');
grid on;
axis([0, 1, -5000, 5000]);
title(sprintf('3.Audio Signal w/ Noise, SNR=%ddB', SNR));

%% S12.9 Band-pass IIR Filter Coefficients
B=[0.00791270139818323  -0.0153622509017829 0.0130375556788600  0   -0.0130375556788600 0.0153622509017829  -0.00791270139818323];
A=[1    -3.02618408203125   5.67168356478214    -6.32709398636416   4.98366925208438    -2.33539979956777   0.678117861407372];

ORDER=length(B)-1;

K=2^12;
KB=K;
KA=K;

B=round(B*KB);
A=round(A*KA);

vldt(max(abs(B)));
vldt(max(abs(A)));

N=2048;
subplot(4,2,7);
plot(0:fs/N/2:(fs/2-fs/N/2), db(freqz(B/KB,A/KA,N)),'LineSmoothing','On');
grid on;
axis([0 fs/2 -60 10]);
title('4.IIR filter');

%% Filter
Y=zeros(1,length(X));
Z=zeros(1,ORDER);

for i=1:length(X)
    for n=1:ORDER+1
        if n==1
            Y(i)=Z(n)+floor(X(i)*B(n)/KB);
            vldt( X(i)*B(n)/KB );
            vldt( Y(i) );
        elseif n==ORDER+1
            Z(n-1)=floor(X(i)*B(n)/KB)-floor(Y(i)*A(n)/KA);
            vldt( Y(i)*A(n)/KA );
            vldt( X(i)*B(n)/KB );
            vldt( Z(n-1) );
        else
            Z(n-1)=Z(n)+floor(X(i)*B(n)/KB)-floor(Y(i)*A(n)/KA);
            vldt( Y(i)*A(n)/KA );
            vldt( X(i)*B(n)/KB );
            vldt( Z(n-1) );
        end
    end
end

subplot(4,2,2);
plot(t,Y,'LineSmoothing','On');
grid on;
axis([0, 1, -3000, 3000]);
title('5.Filtered signal');

%% Rectification
for i=1:length(X)
    Y(i) = abs(Y(i));
end
clear Yq;

subplot(4,2,4);
plot(t,Y,'LineSmoothing','On');
grid on;
axis([0, 1, -1000, 2500]);
title('6.Rectified');

%% Envelope detection
linear_envelope_detection_thresh = 12;
for i=1:length(X)
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

subplot(4,2,6);
plot(t,Y,'LineSmoothing','On');
grid on;
axis([0, 1, -1000, 1500]);
title('7.Envelope Detection');

%% Decisioned
max_env = max(Y(round(length(X)/5):length(X)));
min_env = min(Y(round(length(X)/5):length(X)));
decision_thresh = (min_env+max_env)/2;

min_env = min_env/max_env;
decision_thresh = decision_thresh/max_env;
Y = Y/max_env;
max_env = 1;

Yd = (Y>decision_thresh);

subplot(4,2,8);
plot(t,Y,'LineSmoothing','On','Color',[1,0.6,0.6]);
hold on;
plot([min(t) max(t)],[decision_thresh decision_thresh],'--','LineSmoothing','On','Color',[0.6,1,0.6],'LineWidth',2);
plot(t,Yd,'LineSmoothing','On');
hold off;
grid on;
axis([0, 1, -0.5, 1.5]);
title('8.Decisioned');
