function [ z_test ] = EECM_func_interp_2D( xy_test,  x, y, z )
z_test=zeros(size(xy_test,1),1);
for ii=1:size(z_test,1)
    %% x-dimension index
    [n1,n2] = grid_find(xy_test(ii,1), x);
    
    %% y-dimension index    
    [m1,m2] = grid_find(xy_test(ii,2), y);
    
    %% Corner values
    x_n1 = x(n1);
    x_n2 = x(n2);
    y_m1 = y(m1);
    y_m2 = y(m2);
    z_n1_m1 = z(n1,m1);
    z_n1_m2 = z(n1,m2);
    z_n2_m1 = z(n2,m1);
    z_n2_m2 = z(n2,m2);
    
    %% y_dimension interpolation
    if m1 == m2
        z_n1 = 0.5*z_n1_m1 + 0.5*z_n1_m2;
        z_n2 = 0.5*z_n2_m1 + 0.5*z_n2_m2;
    else
        z_n1 = (y_m2 - xy_test(ii,2))/(y_m2 - y_m1)*z_n1_m1 + (xy_test(ii,2) - y_m1)/(y_m2 - y_m1)*z_n1_m2;
        z_n2 = (y_m2 - xy_test(ii,2))/(y_m2 - y_m1)*z_n2_m1 + (xy_test(ii,2) - y_m1)/(y_m2 - y_m1)*z_n2_m2;
    end
    
    %% x_dimension interpolation
    if n1 == n2
        z_test(ii) = 0.5*z_n1 + 0.5*z_n2;
    else
        z_test(ii) = (x_n2 - xy_test(ii,1))/(x_n2 - x_n1)*z_n1 + (xy_test(ii,1) - x_n1)/(x_n2 - x_n1)*z_n2;
    end
    
end
end