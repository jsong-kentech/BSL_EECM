function [IntVar] = EECM_func_RR_cycle(Config, IntVar)
%% Inilization (Every cycle)
IntVar.dt = Config.dt; % **NA define in sim config
IntVar.T_cyclelife_amb = Config.T_cyclelife_amb;
IntVar.T_bucket_now = Config.MSC_T_bucket;

T_now = IntVar.T_cyclelife_amb;
SOC_now = Config.SOC0;
I_now = 0;

[Rss_now] = EECM_func_interp_3D(Config.RR.Temp_grid, Config.RR.Rate_grid, Config.RR.Rss, T_now, I_now, SOC_now, [1,2]);
OCV_now = EECM_func_interp_2D( [SOC_now, T_now], Config.OCV.SOC, Config.OCV.Temp, Config.OCV.OCV );
V_now = OCV_now + I_now*IntVar.Cap_now *Rss_now;
Sol = zeros(1);
time = 0;
i_step = 1;
charge_flag = 1; % start by charging


indx_top = i_step;

%% Simulation
thermal_dyanmics_flag = Config.thermal_dyanmics_flag;

while i_step < 98*3600/Config.dt && charge_flag==1
    
    %%% Get MSC at temp
    [IntVar] = EECM_func_MSC_at_T(T_now, IntVar, Config); 
    
    %%% MSC simluation   
    [I_now, V_now, Vref_now, Vcath_now, charge_flag, isCC, isATC] = EECM_func_MSC_step(T_now, V_now, SOC_now, OCV_now, [], IntVar, Config);
    

    %%% Record solution
    Sol(i_step, 1) = time;
    Sol(i_step, 2) = I_now;
    Sol(i_step, 3) = V_now;
    Sol(i_step, 4) = Vref_now;
    Sol(i_step, 5) = T_now;
    Sol(i_step, 6) = 0; % space holder
    Sol(i_step, 7) = SOC_now;
    Sol(i_step, 8) = SOC_now;
    Sol(i_step, 9) = Vcath_now;
    Sol(i_step, 10) = IntVar.T_tier;
    Sol(i_step, 11) = isCC;
    Sol(i_step, 12) = isATC;
    
    %%% States update
    T_input = Config.T_charging;
    [time, SOC_now, ~, T_now, OCV_now, ~, IntVar] = states_update(time, SOC_now, [], T_now, OCV_now, I_now, V_now, Config, IntVar, T_input, thermal_dyanmics_flag);   
    i_step = i_step + 1;

    if I_now <= Config.MSC_I_orig(end)
        charge_flag = 0;
    end
end

SOC_top = max(Sol(indx_top:i_step-1, 8));

Sol(indx_top:i_step-1, 8) = Sol(indx_top:i_step-1, 8)/SOC_top;
indx_top = i_step;

%% Record results
% IntVar.charge_data_rec(IntVar.k_cycle_now).t = Sol(:, 1);
% IntVar.charge_data_rec(IntVar.k_cycle_now).T = Sol(:, 5);
% IntVar.charge_data_rec(IntVar.k_cycle_now).I = Sol(:, 2);
% IntVar.charge_data_rec(IntVar.k_cycle_now).V= Sol(:, 3);
% IntVar.charge_data_rec(IntVar.k_cycle_now).Vref = Sol(:, 4);
% IntVar.charge_data_rec(IntVar.k_cycle_now).SOC = Sol(:, 7);
% IntVar.charge_data_rec(IntVar.k_cycle_now).PB_active_bit = Sol(:, 6);
% IntVar.charge_data_rec(IntVar.k_cycle_now).GGSOC = Sol(:, 7)/Sol(end, 7);
% IntVar.charge_data_rec(IntVar.k_cycle_now).Vcath = Sol(:, 9);
% IntVar.charge_data_rec(IntVar.k_cycle_now).T_tier = Sol(:, 10);
% IntVar.charge_data_rec(IntVar.k_cycle_now).isCC = Sol(:, 11);
% IntVar.charge_data_rec(IntVar.k_cycle_now).isATC = Sol(:, 12);

%% Rest after C
EOC_time = time;

time_rest = Config.t_rest_after_C;


IntVar.dt = min(100,Config.t_rest_after_C/20);

while time < time_rest + EOC_time
    I_now = 0;
    [V_now, Vref_now, Vcath_now] = EECM_func_CC_step(Config, IntVar, I_now, T_now, OCV_now, SOC_now, []);
    
    Sol(i_step, 1) = time;
    Sol(i_step, 2) = I_now;
    Sol(i_step, 3) = V_now;
    Sol(i_step, 4) = Vref_now;
    Sol(i_step, 5) = T_now;
    Sol(i_step, 6) = 0; % space holder
    Sol(i_step, 7) = SOC_now;
    Sol(i_step, 8) = SOC_now;
    Sol(i_step, 9) = Vcath_now;
    
    T_input = Config.T_rest_after_C;
    [time, SOC_now, ~, T_now, OCV_now, ~, IntVar] = states_update(time, SOC_now, [], T_now, OCV_now, I_now, V_now, Config, IntVar, T_input, thermal_dyanmics_flag);   
    i_step = i_step + 1;
end

SOC_top = max(Sol(indx_top:i_step-1, 8));


Sol(indx_top:i_step-1, 8) = Sol(indx_top:i_step-1, 8)/SOC_top;
indx_top = i_step;



%% Discharge
EOR_time = time;
IntVar.dt = Config.dt;
time_discharge = Config.t_discharge;

while time < time_discharge + EOR_time && V_now > Config.Vmin
    
    I_now = -Config.disch_C_rate;
    [V_now, Vref_now, Vcath_now] = EECM_func_CC_step(Config, IntVar, I_now, T_now, OCV_now, SOC_now, []);
    
    Sol(i_step, 1) = time;
    Sol(i_step, 2) = I_now;
    Sol(i_step, 3) = V_now;
    Sol(i_step, 4) = Vref_now;
    Sol(i_step, 5) = T_now;
    Sol(i_step, 6) = 0; % space holder
    Sol(i_step, 7) = SOC_now;
    Sol(i_step, 8) = SOC_now;
    Sol(i_step, 9) = Vcath_now;
    T_input = Config.T_discharge;

    [time, SOC_now, ~, T_now, OCV_now, ~, IntVar] = states_update(time, SOC_now, [], T_now, OCV_now, I_now, V_now, Config, IntVar, T_input, thermal_dyanmics_flag);   
    i_step = i_step + 1;
end
% when jump out of the while loop, the final step is not executed
SOC_now = Sol(end, 7);
T_now = Sol(end, 5);
OCV_now = EECM_func_interp_2D( [SOC_now, T_now], Config.OCV.SOC, Config.OCV.Temp, Config.OCV.OCV);

%% Rest after discharge

EOD_time = time;
time_rest = Config.t_rest_after_D;

IntVar.dt = min(100,time_rest/20);

while time < time_rest + EOD_time
       
    I_now = 0;
    [V_now, Vref_now, Vcath_now] = EECM_func_CC_step(Config, IntVar, I_now, T_now, OCV_now, SOC_now, []);
    
    Sol(i_step, 1) = time;
    Sol(i_step, 2) = I_now;
    Sol(i_step, 3) = V_now;
    Sol(i_step, 4) = Vref_now;
    Sol(i_step, 5) = T_now;
    Sol(i_step, 6) = 0; % space holder
    Sol(i_step, 7) = SOC_now;
    Sol(i_step, 8) = SOC_now;
    Sol(i_step, 9) = Vcath_now;
    
    T_input = Config.T_rest_after_D;
    [time, SOC_now, ~, T_now, OCV_now, ~, IntVar] = states_update(time, SOC_now, [], T_now, OCV_now, I_now, V_now, Config, IntVar, T_input, thermal_dyanmics_flag);   
    i_step = i_step + 1;
end

Sol(indx_top:i_step-1, 8) = Sol(indx_top:i_step-1, 8)/SOC_top; % for all of discharge and rest after discharge.

IntVar.t_all = Sol(:, 1);
IntVar.I_all = Sol(:, 2);
IntVar.V_all = Sol(:, 3);
IntVar.T_all = Sol(:, 5);
IntVar.Vref_all = Sol(:, 4);
IntVar.Vcath_all = Sol(:, 9);
IntVar.SOC_all = Sol(:, 7);
IntVar.GGSOC_all = Sol(:, 8);

end
