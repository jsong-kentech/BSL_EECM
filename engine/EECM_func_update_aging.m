function [IntVar] = EECM_func_update_aging(Config,IntVar)

% This function calculate d/dt of aging metrics, such as Cap, R, and so
% on..
% 230927: based on 3Para_v02

%[IntVar.Swell_alpha, IntVar.Swell_beta, IntVar.Cap_fade_alpha, IntVar.Cap_fade_beta, IntVar.WRc_alpha, IntVar.WRc_beta, IntVar.WRa_alpha, IntVar.WRa_beta] = Get_Aging_Param_T_now_v4(Config.opt_para_all,IntVar.T_all);
Vcath_now = IntVar.Vcath_all;
Vref_now = IntVar.Vref_all;
t_Vref = IntVar.t_all;

%% Swell -> skip

%% Cap Fade
VV = ((IntVar.I_all>=0).*IntVar.I_all*IntVar.Cap_now/Config.I_1C).*(exp(Vref_now*Config.aging_para.cap_fade.beta1_all').*Config.aging_para.cap_fade.alpha_all') + ...
     (IntVar.I_all>=0).*(exp((Vcath_now - Config.V_th)*Config.aging_para.cap_fade.beta2_all').*Config.aging_para.cap_fade.gamma_all');

% min(VV(:,1)-VV(:,2))
% min(VV(:,2)-VV(:,3)) 

[R_CF] = eval_aging_rate(IntVar.T_all,Config.aging_para.cap_fade.Temp_grid, VV);

CF_rate_this_cyle = 0.005*trapz(t_Vref,R_CF);

IntVar.cap_fade_now = IntVar.cap_fade_now + CF_rate_this_cyle;
if abs(IntVar.cap_fade_now)>50
   disp('Cap. Fade is larger than 50%. Is it correct?') 
end
IntVar.Cap_now = Config.Cap0*(100+IntVar.cap_fade_now)/100;

%% WRc growth
VV = ((IntVar.I_all>=0).*IntVar.I_all*IntVar.Cap_now/Config.I_1C).*exp(Vref_now*Config.aging_para.WRc_growth.beta_all').*Config.aging_para.WRc_growth.alpha_all' +...
     exp((Vcath_now - Config.V_th)*Config.aging_para.WRc_growth.beta2_all').*Config.aging_para.WRc_growth.gamma_all';
[R_WRc] = eval_aging_rate(IntVar.T_all, Config.aging_para.WRc_growth.Temp_grid, VV);

% min(VV(:,2)-VV(:,1))
% min(VV(:,3)-VV(:,2)) 

WRc_growth_rate_this_cyle = trapz(t_Vref,R_WRc);
IntVar.dWRc_now_in_percent = IntVar.dWRc_now_in_percent+WRc_growth_rate_this_cyle;

%% WRa growth
VV = ((IntVar.I_all>=0).*IntVar.I_all*IntVar.Cap_now/Config.I_1C).*exp(Vref_now*Config.aging_para.WRa_growth.beta_all').*Config.aging_para.WRa_growth.alpha_all' +...
     exp((Vcath_now - Config.V_th)*Config.aging_para.WRa_growth.beta2_all').*Config.aging_para.WRa_growth.gamma_all';
[R_WRa] = eval_aging_rate(IntVar.T_all, Config.aging_para.WRa_growth.Temp_grid, VV);

% min(VV(:,2)-VV(:,1))
% min(VV(:,3)-VV(:,2)) 
    
WRa_growth_rate_this_cyle = trapz(t_Vref,R_WRa);
IntVar.dWRa_now_in_percent = IntVar.dWRa_now_in_percent+WRa_growth_rate_this_cyle;
% IntVar.dWRa_rest_in_percent = IntVar.dWRa_rest_in_percent + trapz(t_Vref(IntVar.i_rest(1):IntVar.i_rest(end)),R_WRa(IntVar.i_rest(1):IntVar.i_rest(end)));
% temporally skipped

%%
IntVar.t_clock = IntVar.t_clock + t_Vref(end) - t_Vref(1);
end