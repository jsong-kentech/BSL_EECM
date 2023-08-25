function [y_interp] = EECM_func_interp_3D(Temp_grid, Rate_grid, y_matrix, T_now, I_now, x_now, indx_interp)

if I_now<0
   error('I_now cannot be negative!!!') 
end

c2k = 273.15;
[n1,n2] = grid_find(T_now, Temp_grid);
[m1,m2] = grid_find(I_now, Rate_grid);

n2 = max(2,n2);
n1 = min(length(Temp_grid)-1,n1);
% m2 = max(2,m2);
% m1 = min(length(Rate_grid)-1,m1);

y_n1_m1 = Interp_1D(x_now, y_matrix{n1,m1}(:,indx_interp(1)), y_matrix{n1,m1}(:,indx_interp(2)));
y_n2_m1 = Interp_1D(x_now, y_matrix{n2,m1}(:,indx_interp(1)), y_matrix{n2,m1}(:,indx_interp(2)));
y_n1_m2 = Interp_1D(x_now, y_matrix{n1,m2}(:,indx_interp(1)), y_matrix{n1,m2}(:,indx_interp(2)));
y_n2_m2 = Interp_1D(x_now, y_matrix{n2,m2}(:,indx_interp(1)), y_matrix{n2,m2}(:,indx_interp(2)));

if m1~=m2
    y_interp_n1 = (y_n1_m2 - y_n1_m1)/(Rate_grid(m2)-Rate_grid(m1))*(I_now-Rate_grid(m1)) + y_n1_m1;
    y_interp_n2 = (y_n2_m2 - y_n2_m1)/(Rate_grid(m2)-Rate_grid(m1))*(I_now-Rate_grid(m1)) + y_n2_m1;
else
    y_interp_n1 = 0.5*y_n1_m2 + 0.5*y_n1_m1;
    y_interp_n2 = 0.5*y_n2_m2 + 0.5*y_n2_m1;
end

if y_interp_n1>0 && y_interp_n2>0
    y_interp = exp((log(y_interp_n2) - log(y_interp_n1))/(1/(Temp_grid(n2)+c2k)-1/(Temp_grid(n1)+c2k))*(1/(T_now+c2k)-1/(Temp_grid(n1)+c2k)) + log(y_interp_n1));
elseif y_interp_n1<0 && y_interp_n2<0
    y_interp = -exp((log(-y_interp_n2) - log(-y_interp_n1))/(1/(Temp_grid(n2)+c2k)-1/(Temp_grid(n1)+c2k))*(1/(T_now+c2k)-1/(Temp_grid(n1)+c2k)) + log(-y_interp_n1));
else
    y_interp = (y_interp_n2 - y_interp_n1)/(Temp_grid(n2)-Temp_grid(n1))*(T_now - Temp_grid(n1)) + y_interp_n1;
end

