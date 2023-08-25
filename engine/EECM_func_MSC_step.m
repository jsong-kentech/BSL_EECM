function [I_converge, V_converge, Vref_converge, Vcath_converge, charge_flag, isCC, isATC] = EECM_func_MSC_step(T_now, V_now, SOC_now, OCV_now, delta_WRc_now_at_T, IntVar, Config)

V_tiers = IntVar.MSC_V;
V_tiers(1) = -inf;
charge_flag = 1;
% V_top = max(VATV_extend);


[n1,n2] = grid_find(T_now, Config.RR.Temp_grid);
[k1,k2] = grid_find(SOC_now, Config.RR.SOC_grid);

tier_now = find(V_tiers>=V_now,1,'first')-1;
if isempty(tier_now)
    tier_now = length(V_tiers)-1;
end
converge_flag =0;
isCC = 0;
isATC = 0;


while tier_now<length(V_tiers) && converge_flag==0

    V_lb = V_tiers(tier_now);
    V_ub = V_tiers(tier_now+1);
    
    % calculate as if CC.
    I_test1 = IntVar.MSC_I(tier_now);
    [m1,m2] = grid_find(I_test1, Config.RR.Rate_grid);
    [Rss_fresh] = EECM_func_interp_3D_modified(Config.RR.Temp_grid, Config.RR.Rate_grid,  Config.RR.SOC_grid, Config.RR.Rss, [n1,n2;m1,m2;k1,k2],[T_now, I_test1, SOC_now], [1,2]);
    Rss_now = Rss_fresh;% + delta_WRc_now_at_T;
    V_test1 = OCV_now + I_test1*IntVar.Cap_now *Rss_now;
    
    if V_test1 > V_ub 
        I_test2 = IntVar.MSC_I(tier_now+1);
        [m1,m2] = grid_find(I_test2, Config.RR.Rate_grid);
        [Rss_fresh] = EECM_func_interp_3D_modified(Config.RR.Temp_grid, Config.RR.Rate_grid,  Config.RR.SOC_grid, Config.RR.Rss, [n1,n2;m1,m2;k1,k2],[T_now, I_test2, SOC_now], [1,2]);
        Rss_now = Rss_fresh;% + delta_WRc_now_at_T;
        V_test2 = OCV_now + I_test2*IntVar.Cap_now *Rss_now;
        
        if V_test2 > V_ub
            tier_now = tier_now +1;
            converge_flag =0;           
        
        else % CV
            V_set = V_ub;
            I_test = I_test1;
            V_test = V_test1;
            V_0 = OCV_now + 0*IntVar.Cap_now *Rss_now;
            iter = 1;
            while iter<100 && abs(V_set - V_test) > 1e-5 % converging I-V CV
                I_test = (V_set - V_0)/(V_test - V_0)*I_test;
%                 if I_test<0
%                     I_test
%                 end
                [m1,m2] = grid_find(I_test, Config.RR.Rate_grid);
                [Rss_fresh] = EECM_func_interp_3D_modified(Config.RR.Temp_grid, Config.RR.Rate_grid,  Config.RR.SOC_grid, Config.RR.Rss, [n1,n2;m1,m2;k1,k2],[T_now, I_test, SOC_now], [1,2]);
                Rss_now = Rss_fresh;% + delta_WRc_now_at_T;
                V_test = OCV_now + I_test*IntVar.Cap_now *Rss_now;
                iter = iter + 1;
            end
            if iter<100
                
                I_converge = I_test;
                V_converge = V_test;
                converge_flag = 1;
            else
                error('Calculation does not get converge')
            end
        end
        
        
    elseif V_test1<=V_lb
        tier_now = tier_now -1;
        converge_flag =0;
    else % if not CV, take CC colution.
        I_converge = I_test1;
        V_converge = V_test1;
        converge_flag = 1;
        isCC = 1;
    end
end


if tier_now==length(V_tiers) && converge_flag==0 % last tier
    
    
    V_set = V_tiers(tier_now);
    I_test = I_test1;
    V_test = V_test1;
    
    V_0 = OCV_now + 0*IntVar.Cap_now *Rss_now;
    iter = 1;
    while iter<100 && abs(V_set - V_test) > 1e-5
        I_test = (V_set - V_0)/(V_test - V_0)*I_test;
%         if I_test<0
%             I_test
%         end
        [m1,m2] = grid_find(I_test, Config.RR.Rate_grid);
        [Rss_fresh] = EECM_func_interp_3D_modified(Config.RR.Temp_grid, Config.RR.Rate_grid,  Config.RR.SOC_grid, Config.RR.Rss, [n1,n2;m1,m2;k1,k2],[T_now, I_test, SOC_now], [1,2]);
        Rss_now = Rss_fresh;% + delta_WRc_now_at_T;
        V_test = OCV_now + I_test*IntVar.Cap_now *Rss_now;
        iter = iter + 1;
    end
    if iter<100
        
        I_converge = I_test;
        V_converge = V_test;
        converge_flag = 1;
        charge_flag = 0;
    else
        converge_flag = 0;
    end
       
end



if converge_flag ==0
    error('Calculation does not converge')
end




[m1,m2] = grid_find(I_converge, Config.RR.Rate_grid);
[Vref_fresh] = EECM_func_interp_3D_modified(Config.RR.Temp_grid, Config.RR.Rate_grid,  Config.RR.SOC_grid, Config.RR.Vref, [n1,n2;m1,m2;k1,k2],[T_now, I_converge, SOC_now], [1,2]);
[Vcath_fresh] = EECM_func_interp_3D_modified(Config.RR.Temp_grid, Config.RR.Rate_grid,  Config.RR.SOC_grid, Config.RR.Vref, [n1,n2;m1,m2;k1,k2],[T_now, I_converge, SOC_now], [1,3]);
Vref_converge = Vref_fresh; % - Config.Rfilm_coeff*delta_WRc_now_at_T*I_converge*IntVar.Cap_now;
Vcath_converge = Vcath_fresh; % + (1-Config.Rfilm_coeff)*delta_WRc_now_at_T*I_converge*IntVar.Cap_now;

end

