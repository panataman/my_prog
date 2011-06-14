function [r, grid_system, wind_power_intigrated] = probe(config_grid)
    %% this function estimates:
    % a) r = load_matrix for power flow simulator
    % b) grid_system = supermarket system whit all estimatet values and parameters
    % c) b = matrix whit provided and intigrated electric power
    % here are indices of time the simulation should run
    number_steps = 24;
    number_days = 36;
   % the grid system will be initialisated
    grid_system = Power_grid(config_grid, number_steps, number_days);

    %% wind power data form wind generator
    [ operating_gen_output_RT, operating_gen_output_RT_brutto, prommised_gen_output_DA_brutto, diff_RT_DA ] = estimator_power_for_load_brutto;
    r = zeros(size(operating_gen_output_RT));
    wind_power_intigrated = zeros([size(operating_gen_output_RT) 2]);

    %% loop speeks on jeach bus of the electric power grid system
    for w = 1 : number_days

        for l = 1 : number_steps

            [fridges_range_for_load_RT, hourly_demand_out] = grid_system.new_cooling_strategy.strategy_calculator(grid_system.busses, grid_system.hourly_demand_day, ...
                grid_system.hourly_demand_night, w, l, operating_gen_output_RT_brutto(:,l,w), prommised_gen_output_DA_brutto(:,l,w), operating_gen_output_RT(:,l,w), ...
		number_steps, number_days, diff_RT_DA);

            for m = 1:length(fridges_range_for_load_RT(:,1))

                [s,i,j] = indices_estimator_main_equation(fridges_range_for_load_RT,m);
                
                % MAIN_EQUATION FOR SIMULATION
                grid_system.busses(s).supermarkets(i).refrigerators(j).main_equation(number_steps, ...
                    l,w,i,j,fridges_range_for_load_RT(m,6),fridges_range_for_load_RT(m,7));
                
                % THE RETURN LOAD OUTPUTPMATRIX of the probe function WILL BE WRITTEN
                r(s,l,w) = r(s,l,w) + fridges_range_for_load_RT(m,11);
                
                % THE RETURN ELECTRIC POWER INTIGRATION MATRIX
                % overall electric power consum
                wind_power_intigrated(s,l,w,1) = wind_power_intigrated(s,l,w,1) + fridges_range_for_load_RT(m,11);
                
                % overall electric power intigrated
                wind_power_intigrated(s,l,w,2) = wind_power_intigrated(s,l,w,2) + fridges_range_for_load_RT(m,12);
                
            end
            
            r(s,l,w) = r(s,l,w) - hourly_demand_out;
            
        end
    end
    
    function [s, i, j] = indices_estimator_main_equation( ...
            fridges_range_for_load_RT,m)
        % estimates indices for main equation
        s = fridges_range_for_load_RT(m,3); % number_
        i = fridges_range_for_load_RT(m,4);
        j = fridges_range_for_load_RT(m,5);
    end
    
    function [ operating_gen_output_RT, operating_gen_output_RT_brutto, prommised_gen_output_DA_brutto, diff_RT_DA ] = ...
            estimator_power_for_load_brutto
        % load realtime wind power generator data for each bus
        load 'gen_output_RT'
        load 'gen_output_DA'
        gen_output_DA(4:7,:,1);
        operating_gen_output_RT = gen_output_RT(4:7,:,:) - ...
            gen_output_DA(4:7,:,:) * 0.99;
        operating_gen_output_RT_brutto = sum(operating_gen_output_RT);
        prommised_gen_output_DA_brutto = sum(gen_output_DA(4:7,:,:) * 0.01);
        diff_RT_DA = sum(gen_output_RT(4:7,:,:) - 0.99 * gen_output_DA(4:7,:,:));
        
    end
end


