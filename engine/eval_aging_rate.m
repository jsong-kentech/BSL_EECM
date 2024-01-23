function [R] = eval_aging_rate(T_all,Temp_grid, VV)
c2k = 273.15;
R = zeros(1);

for ii = 1:size(VV,1)
    [n1,n2] = grid_find(T_all(ii), Temp_grid);
    n2 = max(2,n2);
    n1 = min(length(Temp_grid)-1,n1);
    T_now = T_all(ii) + c2k;
    T1 = Temp_grid(n1) + c2k;
    T2 = Temp_grid(n2) + c2k;
    y1 = VV(ii,n1);
    y2 = VV(ii,n2);
    if y1>0 && y2>0
        R(ii,1) = exp((log(y2) - log(y1))/(1/T2-1/T1)*(1/T_now-1/T1) + log(y1));
    elseif y1<0 && y2<0
        R(ii,1) = -exp((log(-y2) - log(-y1))/(1/T2-1/T1)*(1/T_now-1/T1) + log(-y1));
    else
        R(ii,1) = (y2 - y1)/(T2-T1)*(T_now - T1) + y1;
    end
end
end

