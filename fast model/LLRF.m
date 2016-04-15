function [voldout, dvoldout, Vamp] = LLRF(Vcav, Vtarget, lpff, vold, dvold, f0, df, cp, ci, Qa, delV, delV2, Pmax, Pold0)

%%-------------------------------------------------------------------------
% Digital LPF on I and Q measurements
%%-------------------------------------------------------------------------

Vlpf = lpfilter(Vcav, lpff, vold);

VI = real(Vlpf);
VQ = imag(Vlpf);
voldout = Vlpf(end);

%%-------------------------------------------------------------------------
% Calculate changes to klystron power to correct for beam loading
%%-------------------------------------------------------------------------

PI = zeros(size(Vcav));
PQ = zeros(size(Vcav));

for i = 1:length(Vcav)
    Idv = (real(Vtarget) - VI(i));
    Qdv = (imag(Vtarget) - VQ(i));
    dvold = Idv + 1i*Qdv + dvold;
    
    temp = real(cp)*Idv + real(ci)*real(dvold) + 1i*(imag(cp)*Qdv + imag(ci)*imag(dvold));
    mag = abs(temp);
    phi = phase(temp);
    if mag > Pmax
        PI(i) = Pmax*cos(phi);
        PQ(i) = Pmax*sin(phi);
    else
        PI(i) = real(temp);
        PQ(i) = imag(temp);
    end
end

dvoldout = dvold;

%%-------------------------------------------------------------------------
% Calculate voltage due to output amplifier response
%%-------------------------------------------------------------------------

Pin0 = [Pold0 PI + 1i*PQ];

[Vamp] = RKamp(Qa, f0, df, Pin0, delV, delV2, Pold0);