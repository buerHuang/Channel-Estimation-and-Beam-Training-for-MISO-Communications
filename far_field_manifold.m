%% array response of the antenna
function a = far_field_manifold(Nt, theta, chi)
    a = 1/sqrt(Nt)*ones(Nt, 1);
    for loop = 1:Nt
        a(loop, 1) = a(loop, 1)*exp(1j*pi*chi*(loop-1)*theta);
    end
end 