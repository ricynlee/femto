%%
clear;
clc;
clf;

vldt = @(v) assert(abs(v) < 32768);

%% Parameters
fs = 24e6/26/128; % sampling rate
fc = fs/2/pi; % central freq

t = 0:1/fs:1; % time axis

%% Generate S16.10 Fixed Pointed Signal
X = awgn(cos(2*pi*fc*t).*(t>1/3).*(t<2/3), 6);
X = round(X*2048);

subplot(4,1,1);
plot(t,X,'LineSmoothing','On');
grid on;
axis([0, 1, -5500, 5500]);

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
subplot(4,1,2);
plot(0:fs/N/2:(fs/2-fs/N/2), db(freqz(B/KB,A/KA,N)),'LineSmoothing','On');
axis([0 fs/2 -60 10]);
grid on;

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

%    % MUL_x_b0
%    xb0=floor(X(i)*B(0+1)/K);
%    % ADD_z0_xb0
%    z0_xb0=Z(0+1)+xb0;
%    Y(i)=z0_xb0; % update Y
%    % MUL_x_b1
%    xb1=floor(X(i)*B(1+1)/K);
%    % MUL_y_a1
%    ya1=-floor(Y(i)*A(1+1)/K);
%    % ADD_z1_xb1_ya1
%    z1_xb1_ya1=Z(1+1)+xb1+ya1;
%    Z(0+1)=z1_xb1_ya1; % update Z0
%    % MUL_x_b2
%    xb2=floor(X(i)*B(2+1)/K);
%    % MUL_y_a2
%    ya2=-floor(Y(i)*A(2+1)/K);
%    % ADD_z2_xb2_ya2
%    z2_xb2_ya2=Z(2+1)+xb2+ya2;
%    Z(1+1)=z2_xb2_ya2; % update Z1
%    % MUL_x_b3
%    xb3=floor(X(i)*B(3+1)/K);
%    % MUL_y_a3
%    ya3=-floor(Y(i)*A(3+1)/K);
%    % ADD_z3_xb3_ya3
%    z3_xb3_ya3=Z(3+1)+xb3+ya3;
%    Z(2+1)=z3_xb3_ya3; % update Z2
%    % MUL_x_b4
%    xb4=floor(X(i)*B(4+1)/K);
%    % MUL_y_a4
%    ya4=-floor(Y(i)*A(4+1)/K);
%    % ADD_xb4_ya4
%    xb4_ya4=xb4+ya4;
%    Z(3+1)=xb4_ya4; % update Z3

subplot(4,1,3);
plot(t,Y,'LineSmoothing','On');
grid on;
axis([0, 1, -5500, 5500]);

subplot(4,1,4);
plot(t,abs([0,Y(2:length(X))-Y(1:length(X)-1)])+abs(Y),'LineSmoothing','On');
grid on;
axis([0, 1, -5500, 5500]);
