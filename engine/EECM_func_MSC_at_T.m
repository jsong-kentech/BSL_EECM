function [IntVar] = EECM_func_MSC_at_T(T_now, IntVar, Config)
%%% Get ATV at temp
    MSC_T_select = floor(T_now);
    IntVar.T_tier = 0;
    
    for ii = 1:size(IntVar.T_bucket_now,1)
        if MSC_T_select >= IntVar.T_bucket_now(ii,1) && MSC_T_select < IntVar.T_bucket_now(ii,2)
            IntVar.T_tier = ii;
        end
    end
    
    if Config.thermal_dyanmics_flag == 0
        IntVar.T_tier = median([1,IntVar.T_tier,size(IntVar.T_bucket_now,1)]);
        if MSC_T_select == IntVar.T_bucket_now(end,2)
            IntVar.T_tier = size(IntVar.T_bucket_now,1);
        end
    end
    
    MSC_I_at_T = zeros(1);
    MSC_V_at_T = zeros(1);
    
    if IntVar.T_tier >=1 && IntVar.T_tier<=size(IntVar.T_bucket_now,1)
        MSC_I_at_T = Config.MSC_I_orig(IntVar.T_tier,:);
        MSC_V_at_T = Config.MSC_V_orig;
 
    end
    
    Cap_scale = 1;

    IntVar.MSC_I = MSC_I_at_T*Cap_scale;
    IntVar.MSC_V = MSC_V_at_T;

end

