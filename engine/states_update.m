function [time, SOC_now, SOC2_now, T_now, OCV_now, delta_WRc_now_at_T, IntVar] = states_update(time, SOC_now, SOC2_now, T_now, OCV_now, I_now, V_now, Config, IntVar, T_const, thermal_dyanmics_flag)
time = time + IntVar.dt;

% SOC2 is for overhang SOC
%SOC_now = SOC_now + I_now*IntVar.dt/3600 - Config.ovh.Qratio/Config.ovh.tau*(SOC_now - SOC2_now)*IntVar.dt;
%SOC2_now = SOC2_now + 1/Config.ovh.tau*(SOC_now - SOC2_now)*IntVar.dt;

% SOC_now = median([0,1,SOC_now + I_now*IntVar.dt/3600]);
SOC_now = SOC_now + I_now*IntVar.dt/3600;

if thermal_dyanmics_flag == 1
    I_pack = I_now*Config.Cap_pack_factor*IntVar.Cap_now;
    lambda = Config.hA/Config.mCp;
    dUdT_now = Interp_1D(SOC_now,Config.Entropy_SOC,Config.Entropy_value);
    Qcell_ire = I_pack*(V_now - OCV_now);
    Qcell_rev = I_pack*dUdT_now*(T_now + Config.c2k);
    q_total = Qcell_ire + Qcell_rev + Config.R_Isquare_R*I_pack^2 + Config.R_IR*abs(I_pack) + Config.Q0_maint*IntVar.Q0_maint_factor*(I_pack>0);

    IntVar.Q_record = [IntVar.Q_record; Qcell_ire, Qcell_rev, q_total];
%     if q_total<0
%         q_total
%     end
    T_now = exp(-lambda*IntVar.dt)*T_now  + ( 1 - exp(-lambda*IntVar.dt))*(q_total + IntVar.T_cyclelife_amb*Config.hA)/Config.hA;
else
    T_now = T_const;
end

%WRc_new_at_T = exp(interp1(1./(Config.WRc_new.Temp_grid + Config.c2k), log(Config.WRc_new.WRc_ave), 1/(T_now + Config.c2k), 'linear','extrap'));
delta_WRc_now_at_T = []; % WRc_new_at_T*IntVar.dWRc_now_in_percent/100;
OCV_now = EECM_func_interp_2D( [SOC_now, T_now], Config.OCV.SOC, Config.OCV.Temp, Config.OCV.OCV );

end

