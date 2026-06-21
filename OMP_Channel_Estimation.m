function [h_OMP, w_OMP, OMP_gain, OMP_rate] = OMP_Channel_Estimation(hc, Nt, DFT, SNR_dB, G, L)

% =============================
% 输入：
% hc        : 真实信道 (1 x Nt)
% Nt        : 天线数
% DFT       : 训练矩阵 (Nt x Nt)
% SNR_dB    : 信噪比
% G         : 字典大小（建议 2Nt~4Nt）
% K         : 稀疏度（路径数）
% =============================

%% Step 1: 构造接收信号（列向量模型）
y_clean = DFT' * hc.';   % (Nt x 1)
y_noisy = awgn(y_clean, SNR_dB);

%% Step 2: 构造角域字典 A (Nt x G)
theta_grid = linspace(-1, 1, G);   % sin(theta)
A = zeros(Nt, G);

for g = 1:G
    A(:, g) = exp(1j * pi * (0:Nt-1)' * theta_grid(g));
end
A = A / sqrt(Nt);

%% Step 3: 构造感知矩阵 Φ (Nt x G)
Phi = DFT' * A;

%% Step 4: OMP
residual = y_noisy;        % (Nt x 1)
support = [];
alpha_hat = zeros(G,1);

for l = 1:L
    
    % ---- 1. 匹配（最关键）----
    proj = abs(Phi' * residual).^2;   % (G x 1)
    [~, idx] = max(proj);
    
    % ---- 2. 更新支持集 ----
    support = unique([support, idx]);
    
    % ---- 3. 构造子字典 ----
    Phi_s = Phi(:, support);   % (Nt x |S|)
    
    % ---- 4. 最小二乘 ----
    alpha_s = (Phi_s' * Phi_s) \ (Phi_s' * y_noisy);
    
    % ---- 5. 更新残差 ----
    residual = y_noisy - Phi_s * alpha_s;
    
end

alpha_hat(support) = alpha_s;

%% Step 5: 重构信道
h_OMP = (A * alpha_hat).';   % (1 x Nt)

%% Step 6: MRT 波束赋形
% w_LS = exp(1j * phase(h_LS')) / sqrt(Nt);
% w_OMP = h_OMP' / norm(h_OMP);
w_OMP = exp(1j * phase(h_OMP')) / sqrt(Nt);

%% Step 7: 阵列增益
OMP_gain = abs(hc * w_OMP)^2;

%% Step 8: 可达速率
SNR_linear = 10^(SNR_dB/10);
OMP_rate = log2(1 + SNR_linear * OMP_gain);

end