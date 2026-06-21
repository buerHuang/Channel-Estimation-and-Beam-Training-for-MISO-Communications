function [H, hc] = far_field_channel(Nt, fc, B, M, tau, theta)

H = zeros( M + 1, Nt);
nn = -(Nt-1)/2:1:(Nt-1)/2;
c = 3e8;


for m = 1:M+1
   if m == M+1
        f = fc;
   else
        f=fc+B/(M)*(m-1-(M-1)/2);
   end


%    at = near_field_manifold( Nt, d, f, r, theta );
   at = far_field_manifold(Nt, theta, f/fc);
%    H(m, :) = f/fc * exp(-1j*2*pi*f*r/c) * at;
   H(m,:) = f/fc * exp(-1j*2*pi*f*tau) * at(:).';
 
end

hc = H(M+1,:);
H = H(1:M,:);
end

