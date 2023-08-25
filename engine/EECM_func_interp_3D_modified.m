function [y_interp] = EECM_func_interp_3D_modified(Temp_grid, Rate_grid, SOC_grid,y_matrix, Index, XYZ , indx_interp)
T_now = XYZ(1);
I_now = XYZ(2);
SOC_now = XYZ(3);

if I_now<0
   error('I_now cannot be negative!!!') 
end

c2k = 273.15;
% [n1,n2] = grid_find(T_now, Temp_grid);
% [m1,m2] = grid_find(I_now, Rate_grid);

n2 = max(2,Index(1,2));
n1 = min(length(Temp_grid)-1,Index(1,1));
m1 = Index(2,1);
m2 = Index(2,2);
k2 = Index(3,2);
k1 = Index(3,1);


%y_n1_m1 = Interp_1D(x_now, y_matrix{n1,m1}(:,indx_interp(1)), y_matrix{n1,m1}(:,indx_interp(2)));
%y_n2_m1 = Interp_1D(x_now, y_matrix{n2,m1}(:,indx_interp(1)), y_matrix{n2,m1}(:,indx_interp(2)));
%y_n1_m2 = Interp_1D(x_now, y_matrix{n1,m2}(:,indx_interp(1)), y_matrix{n1,m2}(:,indx_interp(2)));
%y_n2_m2 = Interp_1D(x_now, y_matrix{n2,m2}(:,indx_interp(1)), y_matrix{n2,m2}(:,indx_interp(2)));
if k1~=k2
    y_n1_m1 = (y_matrix{n1,m1}(k2,indx_interp(2)) - y_matrix{n1,m1}(k1,indx_interp(2)))/(SOC_grid(k2)-SOC_grid(k1))*(SOC_now-SOC_grid(k1)) + y_matrix{n1,m1}(k1,indx_interp(2));
    y_n2_m1 = (y_matrix{n2,m1}(k2,indx_interp(2)) - y_matrix{n2,m1}(k1,indx_interp(2)))/(SOC_grid(k2)-SOC_grid(k1))*(SOC_now-SOC_grid(k1)) + y_matrix{n2,m1}(k1,indx_interp(2));
    y_n1_m2 = (y_matrix{n1,m2}(k2,indx_interp(2)) - y_matrix{n1,m2}(k1,indx_interp(2)))/(SOC_grid(k2)-SOC_grid(k1))*(SOC_now-SOC_grid(k1)) + y_matrix{n1,m2}(k1,indx_interp(2));
    y_n2_m2 = (y_matrix{n2,m2}(k2,indx_interp(2)) - y_matrix{n2,m2}(k1,indx_interp(2)))/(SOC_grid(k2)-SOC_grid(k1))*(SOC_now-SOC_grid(k1)) + y_matrix{n2,m2}(k1,indx_interp(2));
else
    y_n1_m1 = 0.5*y_matrix{n1,m1}(k2,indx_interp(2)) + 0.5*y_matrix{n1,m1}(k1,indx_interp(2));
    y_n2_m1 = 0.5*y_matrix{n2,m1}(k2,indx_interp(2)) + 0.5*y_matrix{n2,m1}(k1,indx_interp(2));
    y_n1_m2 = 0.5*y_matrix{n1,m2}(k2,indx_interp(2)) + 0.5*y_matrix{n1,m2}(k1,indx_interp(2));
    y_n2_m2 = 0.5*y_matrix{n2,m2}(k2,indx_interp(2)) + 0.5*y_matrix{n2,m2}(k1,indx_interp(2));
end

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

