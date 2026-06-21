function [h_MMSE, w_MMSE, MMSE_gain, MMSE_rate] = MMSE_Channel_Estimation(hc, Nt, DFT, SNR_dB)

% 输入：
% hc        : 真实信道（1 x Nt）
% Nt        : 天线数
% SNR_dB    : 信噪比（dB）
%
% 输出：
% h_MMSE   : MMSE估计信道
% w_MMSE   : MRT波束赋形向量
% MMSE_gain: 阵列增益
% MMSE_rate: 可达速率

%% Step 1: 构造DFT训练矩阵
% DFT = (1/sqrt(Nt)) * exp(-1i*pi*[0:Nt-1]' * (-(Nt-1)/2:(Nt-1)/2) * (2/Nt));

%% Step 2: 构造接收信号（加AWGN噪声）
y_clean = hc * DFT;
y_noisy = awgn(y_clean, SNR_dB);   % 信号归一化，无需 'measured'

%% Step 3: MMSE信道估计
% 对于归一化信道，假设信道方差 sigma_h^2 = 1
SNR_linear = 10^(SNR_dB/10);
R_h = eye(Nt);                 % 信道相关矩阵（单位矩阵，远场独立信道）
sigma2 = 1/SNR_linear;         % 噪声方差（归一化信号功率）

h_MMSE = y_noisy * DFT' * (R_h / (R_h + sigma2 * eye(Nt)));

%% Step 4: MRT波束赋形
w_MMSE = exp(1j * phase(h_MMSE')) / sqrt(Nt);

%% Step 5: 阵列增益
y_eff = hc * w_MMSE;
MMSE_gain = abs(y_eff)^2;

%% Step 6: 可达速率
MMSE_rate = log2(1 + SNR_linear * MMSE_gain);

end