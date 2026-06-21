function [h_OMP, w_OMP, OMP_gain, OMP_rate] = ...
    OMP_IGW_Channel_Estimation(...
    hc, Nt, DFT, SNR_dB, G, L)

% ==========================================================
% OMP + IGW (Iterative Grid Weighting)
%
% 输入:
% hc      : 真实信道 (1×Nt)
% Nt      : 天线数
% DFT     : 训练矩阵
% SNR_dB  : 信噪比
% G       : 粗网格字典大小
% L       : 路径数
%
% 输出:
% h_OMP
% w_OMP
% OMP_gain
% OMP_rate
% ==========================================================

%% =========================================================
% Step 1 : 接收信号
%% =========================================================

y_clean = DFT' * hc.';

y_noisy = awgn(y_clean,SNR_dB);

%% =========================================================
% Step 2 : 粗网格字典
%% =========================================================

theta_grid = linspace(-1,1,G);

A = zeros(Nt,G);

for g = 1:G

    A(:,g) = ...
        exp(1j*pi*(0:Nt-1)'*theta_grid(g));

end

A = A/sqrt(Nt);

%% =========================================================
% Step 3 : 感知矩阵
%% =========================================================

Phi = DFT' * A;

%% =========================================================
% Step 4 : OMP
%% =========================================================

residual = y_noisy;

support = [];

alpha_hat = zeros(G,1);

for l = 1:L

    proj = abs(Phi' * residual).^2;

    [~,idx] = max(proj);

    support = unique([support idx]);

    Phi_s = Phi(:,support);

    alpha_s = ...
        (Phi_s'*Phi_s)\...
        (Phi_s'*y_noisy);

    residual = ...
        y_noisy - Phi_s*alpha_s;

end

alpha_hat(support) = alpha_s;

%% =========================================================
% Step 5 : Coordinate-Descent IGW
%% =========================================================

theta_refined = theta_grid(support).';

num_refine_iter = 10;

delta0 = 2/G;

for iter_refine = 1:num_refine_iter

    for kk = 1:L

        best_theta = theta_refined(kk);

        best_cost = inf;

        delta = delta0/(2^(iter_refine-1));

        theta_local = linspace( ...
            theta_refined(kk)-delta,...
            theta_refined(kk)+delta,...
            21);

        for m = 1:length(theta_local)

            theta_candidate = theta_refined;

            theta_candidate(kk) = ...
                theta_local(m);

            % ---------------------------------
            % 构造联合字典
            % ---------------------------------

            A_tmp = zeros(Nt,L);

            for ll = 1:L

                A_tmp(:,ll) = ...
                    exp(1j*pi*(0:Nt-1)' ...
                    * theta_candidate(ll));

            end

            A_tmp = A_tmp/sqrt(Nt);

            Phi_tmp = DFT' * A_tmp;

            % ---------------------------------
            % 联合LS估计
            % ---------------------------------

            alpha_tmp = ...
                pinv(Phi_tmp) ...
                * y_noisy;

            residual_tmp = ...
                y_noisy ...
                - Phi_tmp*alpha_tmp;

            cost = norm(residual_tmp)^2;

            if cost < best_cost

                best_cost = cost;

                best_theta = ...
                    theta_local(m);

            end

        end

        theta_refined(kk) = best_theta;

    end

end

%% =========================================================
% Step 5.5 : Final Joint LS
%% =========================================================

A_refined = zeros(Nt,L);

for ll = 1:L

    A_refined(:,ll) = ...
        exp(1j*pi*(0:Nt-1)' ...
        * theta_refined(ll));

end

A_refined = A_refined/sqrt(Nt);

Phi_refined = DFT' * A_refined;

alpha_refined = ...
    pinv(Phi_refined) ...
    * y_noisy;

%% =========================================================
% Step 6 : 重构信道
%% =========================================================

h_OMP_col = ...
    A_refined ...
    * alpha_refined;

h_OMP = h_OMP_col.';

%% =========================================================
% Step 7 : Analog MRT
%% =========================================================

w_OMP = ...
    exp(1j*phase(h_OMP')) ...
    / sqrt(Nt);

%% =========================================================
% Step 8 : Array Gain
%% =========================================================

OMP_gain = abs(hc*w_OMP)^2;

%% =========================================================
% Step 9 : Achievable Rate
%% =========================================================

SNR_linear = 10^(SNR_dB/10);

OMP_rate = ...
    log2( ...
    1 + SNR_linear*OMP_gain);

end