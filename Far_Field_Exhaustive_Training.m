function [h_ES, ES_beam, ES_gain, ES_rate] = Far_Field_Exhaustive_Training(hc, DFT, SNR_dB)
% FAR_FIELD_EXHAUSTIVE_TRAINING_WITH_CE  远场穷举波束训练 + 信道估计恢复
%
% 输入：
%   hc       : 真实信道向量 (1 × Nt)，通常为远场单径信道
%   DFT      : Nt × S 的DFT码本矩阵，每列为归一化的候选波束
%   SNR_dB   : 信噪比（dB）
%
% 输出：
%   h_ES     : 估计出的信道向量 (1 × Nt)，恢复形式为 beta_hat * beam_best'
%   ES_beam  : 选中的最优波束向量 (Nt × 1)
%   ES_gain  : 使用真实信道和最优波束获得的阵列增益（标量功率）
%   ES_rate  : 可达速率（bit/s/Hz），基于真实增益和SNR计算
%
% 说明：
%   - 假设DFT码本各列已归一化（范数为1），以便接收信号直接反映复路径增益。
%   - 噪声添加在每个候选波束的接收信号上，然后选择接收功率最大的波束。
%   - 信道估计直接使用最优波束对应的含噪接收信号作为路径增益的估计，
%     并利用该波束的转向向量重构信道。

    %% 参数初始化
    S = size(DFT, 2);               % 波束总数
    gain_list = zeros(1, S);        % 各波束接收功率
    rx_signal = zeros(1, S);        % 各波束接收信号（含噪复数值）

    %% 穷举搜索：遍历所有波束，采集含噪观测
    for s = 1:S
        beam = DFT(:, s);                    % 当前波束
        y = hc * beam;                       % 无噪接收信号（标量）
        y_noisy = awgn(y, SNR_dB);           % 添加AWGN
        rx_signal(s) = y_noisy;              % 保存含噪观测
        gain_list(s) = abs(y_noisy)^2;       % 接收功率
    end

    %% 选择接收功率最大的波束作为最优波束
    [~, idx_best] = max(gain_list);
    ES_beam = DFT(:, idx_best);

    %% 信道估计：用最优波束的含噪接收信号估计路径增益，并重构信道
    beta_hat = rx_signal(idx_best);           % 复增益估计（标量）
    h_ES = beta_hat * ES_beam';               % 恢复信道向量 (1 × Nt)

    %% 性能指标（基于真实信道）
    ES_gain = abs(hc * ES_beam)^2;            % 真实阵列增益
    SNR_linear = 10^(SNR_dB/10);              % 线性信噪比
    ES_rate = log2(1 + SNR_linear * ES_gain); % 可达速率

end