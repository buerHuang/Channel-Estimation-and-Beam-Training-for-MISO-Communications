clear all; clc; 

%% System parameters
Nt = 32;
fc = 100e9;
B = 3e9;
M = 1;
tau = 10e-9;
G = 4*Nt;
K = 1;

SNR_dB_list = 0:2.5:20;
Num_SNR = length(SNR_dB_list);

% DFT码本
DFT = (1/sqrt(Nt)) * exp(-1i*pi*[0:Nt-1]' * (-(Nt-1)/2:(Nt-1)/2) * (2/Nt));
M = round(Nt/1); % 观测数，压缩感知可以小于 Nt
DFT2 = (randn(M, Nt) + 1j*randn(M, Nt)) / sqrt(2); % 高斯随机矩阵
DFT2 = DFT2';

%% Monte Carlo parameters
num_iter = 500;  % 样本数越大越平滑
theta_range = [-1, 1];

%% 结果初始化
rate_LS = zeros(num_iter,Num_SNR);
rate_MMSE = zeros(num_iter,Num_SNR);
rate_EX = zeros(num_iter,Num_SNR);
rate_perfect = zeros(num_iter,Num_SNR);
rate_OMP = zeros(num_iter, Num_SNR);

%% Monte Carlo循环
parfor snr_idx = 1:Num_SNR
    SNR_dB = SNR_dB_list(snr_idx);
    SNR_linear = 10^(SNR_dB/10);
    
    fprintf('SNR_dB = %.2f dB [%d/%d]\n', SNR_dB, snr_idx, Num_SNR);
    
    for iter = 1:num_iter
        t0 = clock;  % 如果你想打印每次迭代时间
        
        % 随机生成用户角度
        theta = theta_range(1) + (theta_range(2)-theta_range(1))*rand;

        % 生成远场信道
        [H, hc] = far_field_channel(Nt, fc, B, M, tau, theta);

        % ===== Perfect CSI =====
        w_opt = exp(1j*phase(hc'))/sqrt(Nt);
        gain_opt = abs(hc * w_opt)^2;
        rate_perfect(iter, snr_idx) = log2(1 + SNR_linear * gain_opt);

        % ===== LS =====
        [~, ~, ~, rate_tmp] = LS_Channel_Estimation(hc, Nt, DFT, SNR_dB);
        rate_LS(iter, snr_idx) = rate_tmp;

        % ===== MMSE =====
        [~, ~, ~, rate_tmp] = MMSE_Channel_Estimation(hc, Nt, DFT, SNR_dB);
        rate_MMSE(iter, snr_idx) = rate_tmp;

        % ===== DFT Exhaustive =====
        [rate_tmp, ~, ~] = Far_Field_Exhaustive_Training(hc, DFT, SNR_dB);
        rate_EX(iter, snr_idx) = rate_tmp;

        % ===== OMP =====
        [~, ~, ~, OMP_rate] = OMP_Channel_Estimation(hc, Nt, DFT, SNR_dB, G, K);
        rate_OMP(iter, snr_idx) = OMP_rate;


        % 打印迭代时间（可选）
%         fprintf('  run %.4f s [iter %d/%d]\n', etime(clock, t0), iter, num_iter);
    end
end

%% Monte Carlo平均
mean_rate_LS = mean(rate_LS,1);
mean_rate_MMSE = mean(rate_MMSE,1);
mean_rate_EX = mean(rate_EX,1);
mean_rate_OMP = mean(rate_OMP, 1);
mean_rate_perfect = mean(rate_perfect,1);


%% Plot
figure;
plot(SNR_dB_list, mean_rate_perfect, 'r--','LineWidth',1.8); hold on;
plot(SNR_dB_list, mean_rate_LS, 'bo-','LineWidth',1.8);
plot(SNR_dB_list, mean_rate_MMSE, 'd-', 'Color', [1,0,1], 'LineWidth',1.8);
plot(SNR_dB_list, mean_rate_OMP, 'gs-','LineWidth',1.8);
plot(SNR_dB_list, mean_rate_EX, '^-', 'Color',[0,0,0],'LineWidth',1.8);

grid on;
xlabel('SNR (dB)', 'interpreter', 'latex', 'fontsize', 12);
ylabel('Achievable Rate (bit/s/Hz)', 'interpreter', 'latex', 'fontsize', 12);
legend('Perfect CSI','LS','MMSE','OMP', 'DFT Exhaustive','Location','NorthWest', 'interpreter', 'latex', 'fontsize', 12);