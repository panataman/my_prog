function [r, grid_system, multiple_dimension_all_data_matrix, gen_output_real_T, gen_output_day_A] = probe(configuration_grid)
    %% this function estimates:
    % a) r = load_matrix for power flow simulator
    % b) grid_system = supermarket system whit all estimatet values and parameters
    % c) b = matrix whit provided and intigrated electric power

    % here are indices of time the simulation should run
    number_steps = 3;
    number_days = 1;

    %% the grid system will be initialisated
    % in configuration_grid all data about which how many supermarkets are connected on which bus
    grid_system = Power_grid(configuration_grid, number_steps, number_days);
    % this is the real power that wind power can supply
    
    %% wind power data form wind generator
    [ operating_gen_output_RT, operating_gen_output_RT_brutto, prommised_gen_output_DA_brutto, gen_output_real_T, gen_output_day_A ] = ...
        estimator_power_for_load_brutto;
    r = zeros(size(operating_gen_output_RT));
    multiple_dimension_all_data_matrix = zeros([size(operating_gen_output_RT) 6]);
    
    %% loop speeks on jeach bus of the electric power grid system
    for w = 1 : number_days
        
       
        for l = 1 : number_steps
            
            [fridges_range_for_load_RT, hourly_demand_out, power_for_load_out, power_b] = ...
                grid_system.new_cooling_strategy.strategy_calculator( ...
							grid_system.busses, ...
							grid_system.hourly_demand_day, ...
                					grid_system.hourly_demand_night, ...
							w, ...
							l, ...
							gen_output_real_T(:,l,w), ...
							gen_output_day_A(:,l,w), ...
							operating_gen_output_RT_brutto(:,l,w), ...
                					prommised_gen_output_DA_brutto(:,l,w), ...
							operating_gen_output_RT(:,l,w), ...
							number_steps, ...
							number_days);

            for m = 1:length(fridges_range_for_load_RT(:,1))
                
                [s,i,j] = indices_estimator_main_equation(fridges_range_for_load_RT,m);
                
                % MAIN_EQUATION FOR SIMULATION
                grid_system.busses(s).supermarkets(i). ...
                    refrigerators(j).main_equation(number_steps, ...
                    l,w,i,j,fridges_range_for_load_RT(m,5), ...
                    fridges_range_for_load_RT(m,6));
                
                % THE RETURN LOAD OUTPUTPMATRIX of the probe function WILL BE WRITTEN
                r(s,l,w) = r(s,l,w) + fridges_range_for_load_RT(m,10);
                
                % THE RETURN ELECTRIC POWER INTIGRATION MATRIX
                % overall electric power consum
                multiple_dimension_all_data_matrix(s,l,w,1) = hourly_demand_out;%fridges_range_for_load_RT(m,10);
                
                % overall electric power intigrated
                multiple_dimension_all_data_matrix(s,l,w,2) = multiple_dimension_all_data_matrix(s,l,w,2) + fridges_range_for_load_RT(m,11);
                
                % overall power for load
                multiple_dimension_all_data_matrix(s,l,w,3) = power_for_load_out(s);

                % overall wind power diviation
                multiple_dimension_all_data_matrix(s,l,w,4) = gen_output_real_T(s,l,w) - power_b(s);

                % overall power
%                 multiple_dimension_all_data_matrix(s,l,w,5) = multiple_dimension_all_data_matrix(s,l,w,5) + fridges_range_for_load_RT(i,10) - fridges_range_for_load_RT(i,11);
                multiple_dimension_all_data_matrix(s,l,w,5) = multiple_dimension_all_data_matrix(s,l,w,5) + fridges_range_for_load_RT(m,10);
                
                multiple_dimension_all_data_matrix(s,l,w,6) = multiple_dimension_all_data_matrix(s,l,w,5) -  multiple_dimension_all_data_matrix(s,l,w,2);
            end
            
            r(s,l,w) = r(s,l,w) - hourly_demand_out;
            
        end
    end
    
    function [s, i, j] = indices_estimator_main_equation( ...
            fridges_range_for_load_RT,m)
        % estimates indices for main equation
        s = fridges_range_for_load_RT(m,2); % number_bus
        i = fridges_range_for_load_RT(m,3); % number_steps
        j = fridges_range_for_load_RT(m,4); % number_day
    end
    
    function [ operating_gen_output_RT, operating_gen_output_RT_brutto, prommised_gen_output_DA_brutto, gen_output_real_T, gen_output_day_A ] = ...
            estimator_power_for_load_brutto
        % load realtime wind power generator data for each bus
        load 'gen_output_RT'
        load 'gen_output_DA'
        gen_output_day_A = gen_output_DA(4:7,:,1:number_days);
	gen_output_real_T = gen_output_RT(4:7,:,1:number_days);
        operating_gen_output_RT = gen_output_RT(4:7,:,:) - ...
            gen_output_DA(4:7,:,:) * 0.85;
        operating_gen_output_RT_brutto = sum(operating_gen_output_RT);
        prommised_gen_output_DA_brutto = sum(gen_output_DA(4:7,:,:) * 0.15);
        
    end
end


