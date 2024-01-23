function [Config] = EECM_func_cycling_protocol(Config,cycling,charging,T_amb)
% EECM Engine
% Define cycling protocol


%% Transfer variables to Config field
Config.mode = 'simulation'; % or 'fitting'
Config.input_type = 'cycling_protocol'; % or 'load profile'
    % Protocols
    Config.cycling_protocol = cycling;
    Config.charging_protocol = charging;

Config.T_cyclelife_amb = T_amb; % ambient temperature

%% Temperatures
    % setting the step temperatures (temporally same)
    Config.T_charging = Config.T_cyclelife_amb;
    Config.T_rest = Config.T_cyclelife_amb;
    Config.T_discharge = Config.T_cyclelife_amb;
    Config.T_rest_after_C = Config.T_cyclelife_amb;
    Config.T_rest_after_D = Config.T_cyclelife_amb;



%% Cycling Protocol
if strcmp(Config.cycling_protocol,'FCPD')
    Config.t_rest_after_C = 10*60;
    Config.t_rest_after_D = 10*60;
    Config.disch_C_rate = 1;
    Config.t_discharge = 3600/(Config.disch_C_rate)+3600;

elseif strcmp(Config.cycling_protocol,'FCPD-dummy')
    Config.t_rest_after_C = 2*60*60;
    Config.t_rest_after_D = 10*60;
    Config.disch_C_rate = 1;
    Config.t_discharge = 3600/(Config.disch_C_rate)+3600;

elseif strcmp(Config.cycling_protocol,'OCPD')
    Config.t_rest_after_C = 12*3600;
    Config.t_rest_after_D = 4*3600;
    Config.t_discharge = 6*3600;
    Config.disch_C_rate = 0.5;
    Config.t_discharge = 3600/(Config.disch_C_rate)+3600;

% elseif to add later: delayed charging

end


%% Charging Protocol

if strcmp(Config.charging_protocol,'CCCV')
    Config.MSC_T_bucket = [-inf, inf];
    Config.MSC_V_orig = [Config.Vmin, Config.Vmax];
    Config.MSC_I_orig = [0.5         , 1/20];


elseif strcmp(Config.charging_protocol,'2T2CCCV')
    Config.MSC_T_bucket = [-inf, 20; 20 inf];
    Config.MSC_V_orig = [Config.Vmin, 3.5, 4.0 Config.Vmax];
    Config.MSC_I_orig = [0.7, 0.7, 0.4, 1/50; ...
                         2.0, 1.0, 0.4, 1/50];

end





end