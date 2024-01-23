% (EECM)
% Battery Software Lab, KENTECH
% 2023 07 22
% SIMULATION


%% Currently Skipped
% Thermal Effect: config, sim_RR_cycle
% Resistance Growth: config-aging, IntVar.WRc

clear; clc; close all

%% Simulation Setting

% cell
cell_id_string = 'example1'; % used for display and labeling

% environment
T_amb = 25; % ambient temperature
N_cycle = 50; % number of cycles to simulate

% cycling
cycling = 'FCPD';
charging = 'CCCV';

% cycles to display
cycle_display = [1,50,100];



%% Configuration

% cell-specific config
config_EECM_V1_example1
    % config cell dynamic and aging models

% cycling config
Config = EECM_func_cycling_protocol(Config,cycling,charging,T_amb);
    % config cycling and charging protocols

%% Simulation
[Config, IntVar] = EECM_func_internal_variable(Config); % initialize capacity fade variables

for k_cycle = Config.cycle_initial:Config.cycle_last

    fprintf('cycle %.0f.\n', k_cycle) % indicate cycle under simulation
    IntVar.k_cycle_now = k_cycle;

    % run RR model
    IntVar = EECM_func_RR_cycle(Config,IntVar); % calculate internal variables of k-th cycle
    
    % run aging model (In progress)
    IntVar = EECM_func_update_aging(Config,IntVar); % **in progress
    IntVar.cap_fade(IntVar.k_cycle_now-Config.cycle_initial+1,:) = [IntVar.k_cycle_now, IntVar.cap_fade_now];
    
    % Plot by cycle
    if any(ismember(k_cycle,cycle_display))
        figure(1); hold all; grid on;

        subplot(221)
        hold all; grid on;
        plot(IntVar.t_all/3600,IntVar.I_all,'linewidth',2)
        hold on
        xlabel('Time (hr)')
        ylabel('C-rate')
        set(gca,'FontSize',14)
        
        subplot(222)
        hold all; grid on;
        plot(IntVar.t_all/3600,IntVar.V_all,'linewidth',2)
        hold on
        xlabel('Time (hr)')
        ylabel('V')
        set(gca,'FontSize',14)
        
        subplot(223)
        hold all; grid on;
        plot(IntVar.t_all/3600,IntVar.Vref_all,'linewidth',2)
        hold on
        xlabel('Time (hr)')
        ylabel('T (C)')
        set(gca,'FontSize',14)
        
        subplot(224)
        hold all; grid on;
        plot(IntVar.t_all/3600,IntVar.SOC_all,'linewidth',2)
        hold on
        xlabel('Time (hr)')
        ylabel('SOC')
        set(gca,'FontSize',14)        


    end
    
    % Plot cumulatively
    cmat = lines(5);
    figure(2); hold on; box on;
    subplot(4,1,1)
        plot((IntVar.t_all+IntVar.t_clock)/3600,IntVar.V_all,'Color',cmat(1,:),'LineStyle', '-', 'Marker', 'none'); hold on;
        xlabel('Time (hr)')
        ylabel('V_{cell}')
        set(gca,'FontSize',16)     
    subplot(4,1,2)
        plot((IntVar.t_all+IntVar.t_clock)/3600,IntVar.Vref_all,'Color',cmat(2,:),'LineStyle', '-', 'Marker', 'none'); hold on;
        xlabel('Time (hr)')
        ylabel('Vref'); ylim([-0.1,0.2]);yline(0)
        set(gca,'FontSize',16)     
    subplot(4,1,3)
        plot((IntVar.t_all+IntVar.t_clock)/3600,IntVar.SOC_all,'Color',cmat(3,:),'LineStyle', '-', 'Marker', 'none'); hold on;
        xlabel('Time (hr)')
        ylabel('SOC')
       set(gca,'FontSize',16)     
    subplot(4,1,4)
        plot((IntVar.t_all+IntVar.t_clock)/3600,IntVar.I_all,'Color',cmat(4,:),'LineStyle', '-', 'Marker', 'none'); hold on;
        xlabel('Time (hr)')
        ylabel('I')
        set(gca,'FontSize',16)     



    IntVar.t_clock = IntVar.t_clock + IntVar.t_all(end);

end



%% Postprocessing Aging

IntVar.cap_fade = [[0 0];IntVar.cap_fade];


%% Plots
figure(3);
hold all;grid on;
plot(IntVar.cap_fade(:,1),IntVar.cap_fade(:,2),'LineWidth',2, 'color', cmat(2,:))
hold on
% hold on
xlabel('Cycle')
ylabel('Cap Fade (%)')
%title(['Simulation @ ',num2str(T_cyclelife_amb),'^oC Ambient Temperature']);
set(gca,'FontSize',24);

ylim([-10 0])
%}