function [h_LS, w_LS, LS_gain, LS_rate] = LS_Channel_Estimation(hc, Nt, DFT, SNR_dB)

% 输入：
% hc        : 真实信道（1×Nt）
% Nt        : 天线数
% SNR_dB    : 信噪比（dB）

% 输出：
% h_LS      : LS估计信道
% w_LS      : 波束赋形向量
% LS_gain   : 阵列增益
% LS_rate   : 可达速率

%% Step 1: 构造DFT训练矩阵
% DFT = (1/sqrt(Nt)) * exp(-1i*pi*[0:Nt-1]' * (-(Nt-1)/2:(Nt-1)/2) * (2/Nt));

%% Step 2: 构造接收信号（无噪声部分）
y_clean = hc * DFT;

%% Step 3: 加AWGN噪声（自动按SNR）
y_LS = awgn(y_clean, SNR_dB);

%% Step 4: LS信道估计
h_LS = y_LS * DFT';

%% Step 5: MRT波束赋形
w_LS = exp(1j * phase(h_LS')) / sqrt(Nt);

%% Step 6: 阵列增益（注意：此时hc未加噪）
y_eff = hc * w_LS;
LS_gain = abs(y_eff)^2;

%% Step 7: 可达速率（SNR直接来自输入）
SNR_linear = 10^(SNR_dB/10);
LS_rate = log2(1 + SNR_linear * LS_gain);

end