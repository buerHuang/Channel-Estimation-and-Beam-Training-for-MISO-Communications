# Channel Estimation and Beam Training for MISO Communications

<div style="display: flex; flex-wrap: wrap; gap: 20px; justify-content: center;">
  <img src="https://github.com/buerHuang/Channel-Estimation-and-Beam-Training-for-MISO-Communications/blob/main/Rate.svg" alt="Rate_SNR" style="flex: 1; min-width: 100px; max-width: 40%; height: auto;">
  <img src="https://github.com/buerHuang/Channel-Estimation-and-Beam-Training-for-MISO-Communications/blob/main/NMSE.svg" alt="NMSE_SNR" style="flex: 1; min-width: 100px; max-width: 40%; height: auto;">
</div>

This is a demonstration of CSI acquisition via LS, MMSE, OMP, IGW channel estimation and exhaustive beam training.

Based on these codes, you can easily scale communication systems to multi-user and multi-path channels, as well as wideband channels.

far_field_channel: MISO far-field channel is generated and wideband channel generation has been reserved.

far_field_manifold: This generates the far-field manifold (array response) vector.

LS_Channel_Estimation: least squares based channel estimation.

MMSE_Channel_Estimation: Channel estimation based on minimum mean square error.

OMP_Channel_Estimation: Channel estimation with orthogonal matching pursuit.

OMP_IGW_Channel_Estimation: Orthogonal matching pursuit followed by gridless weighted refinement.

**Rate_SNR:** Beamforming is performed by estimating the phase of the channel and calculating the reachable rate.

**NMSE_SNR:** Compare the NMSE of different channel estimation methods as a function of SNR variation.
