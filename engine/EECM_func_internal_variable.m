function [Config,IntVar] = EECM_func_internal_variable(Config)

% EECM Engine
% Define internal variables


IntVar.cap_fade_now = 0;
    IntVar.cap_fade_now1 = 0;
    IntVar.cap_fade_now2 = 0;
    IntVar.cap_fade_now3 = 0;

IntVar.Cap_now = Config.Cap0;

IntVar.dWRa_now_in_percent = 0; % growth rate in percentage; 
IntVar.dWRc_now_in_percent = 0; % growth rate in percentage; 
IntVar.dWRa_rest_in_percent = 0;


IntVar.T_now = Config.T_cyclelife_amb;

IntVar.t_clock = 0; % record the clock time during cycling

IntVar.V_top_rec = [];
IntVar.cap_fade = [];


end