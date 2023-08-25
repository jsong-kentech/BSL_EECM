function [V_now, Vref_now, Vcath_now] = EECM_func_CC_step(Config, IntVar, I_now, T_now, OCV_now, SOC_now, delta_WRc_now_at_T)

T_Vref = T_now;

[Vref_eq] = EECM_func_interp_3D(Config.RR.Temp_grid, Config.RR.Rate_grid, Config.RR.Vref, T_Vref, 0, SOC_now, [1,2]);
[Vcath_eq] = EECM_func_interp_3D(Config.RR.Temp_grid, Config.RR.Rate_grid, Config.RR.Vref, T_Vref, 0, SOC_now, [1,3]);

if round(I_now*1000)==0
    V_now = OCV_now;
     
else    
    [ Rss_discharge ] = EECM_func_interp_2D( [T_now, -I_now],  Config.RR.Temp_grid, Config.RR.Rate_grid, Config.RR.Rss_discharge );
    Rss_now = Rss_discharge;% + delta_WRc_now_at_T;
    V_now = OCV_now + I_now*IntVar.Cap_now*Rss_now;  
       
end

% emprical correction
Vref_now = Vref_eq;% + 0.5*(OCV_now - V_now);
Vcath_now = Vcath_eq;% - 0.5*(OCV_now - V_now);

end