classdef Cooling_strategy < handle
    % NEW_COOLING_STRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function obj = Cooling_strategy
        end % function constructor
        
        function [fridges_range_for_charging_RT, hourly_demand_out, ...
		power_for_load_out, power_b, power_promised] = ...
				strategy_calculator( obj, ...
					buses, ...
					hourly_demand_day, ...
					hourly_demand_night, ...
					count_number_days, ...
					count_number_steps, ...
					gen_output_real_T, ...
					gen_output_day_A, ...
					promised_gen_output_DA_gross, ...
					number_steps, ...
					number_days )

            % This function gives a matrix which contains rang of
            % refrigerators refer to size up time to the critical temperature
            cooling = 0; % 
            count_bus = 0; % initialisation runner
            time_step = 1/60; % incrementally charging
            electric_power_consumption = 0;
            wind_power_integrated = 0; % initialisation runner
            fridges_range_for_charging_RT = zeros(1,11);
            
            for b = 1:length(buses) % each bus
                count_bus = count_bus + 1; % update runner
                count_supermarket = 0; % initialisation runner
                for s = 1 : length(buses(b).supermarkets) %each supermarket
                    count_supermarket = count_supermarket + 1;
                    count_refrigerator = 0;
                    for r = 1:length([buses(b).supermarkets(s).refrigerators])

			% before the estimation of temperature for the next step
			% can be started, the decision for the power, which
			% will be adjudged for each fridge, has be affected
                        [Q_losses,time_to_T_critical_max] = ...
				buses(b).supermarkets(s). ...
				refrigerators(r).sum_all_losses(...
					number_steps, ...
					count_number_steps, ...
					count_number_days, ...
					number_days);
                        
			% this function estimates the heat power the fridge can
			% maximum integrate for the moment
			residual_capacity = buses(b)....
				supermarkets(s). ...
				refrigerators(r). ...
				estimator_full_heat_capacity( ...
					count_number_steps, ...
					count_number_days, ...
					Q_losses);
                        
                        if sum (fridges_range_for_charging_RT) == 0 % securing
                            
                            count_refrigerator = count_refrigerator + 1;
                            fridges_range_for_charging_RT = [...
                                time_to_T_critical_max ...
                                count_bus ...
                                count_supermarket ...
                                count_refrigerator ...
                                cooling ...
                                Q_losses ...
                                time_step ...
                                buses(b).supermarkets(s).refrigerators(r). ...
                                epsilon ...
                                residual_capacity ...
                                electric_power_consumption ...
                                wind_power_integrated ...
                                ];
                            
                        else
                            count_refrigerator = count_refrigerator + 1;
                            fridges_range_for_charging_RT = [...
                                fridges_range_for_charging_RT; ...
                                time_to_T_critical_max ...                    %1
                                count_bus ...                                 %2
                                count_supermarket ...                         %3
                                count_refrigerator ...                        %4
                                cooling ...                                   %5
                                Q_losses ...                                  %6
                                time_step ...                                 %7
                                buses(b).supermarkets(s).refrigerators(r). ...
					epsilon ...                           %8
                                residual_capacity ...                         %9
                                electric_power_consumption ...               %10
                                wind_power_integrated ...                    %11
                                ];
                        end
                    end
                end
            end
            
            % condition for load fridges
            MODUS = 'load';
            
            [power_for_load, hourly_demand] = obj.power_for_load_nett( ...
				count_number_steps, ...
				promised_gen_output_DA_gross, ...
				diff_RT_DA, ...
				hourly_demand_day, ...
				hourly_demand_night);

            hourly_demand_out = hourly_demand;
            power_for_load = power_for_load;

            while strcmp('load', MODUS)
                
                table_to_restock = 0;

                if power_for_load > 0
                    for c = find(fridges_range_for_charging_RT(:,10) > 0)
                        if table_to_restock(1) == 0
                            table_to_restock = [c, ...
				fridges_range_for_charging_RT(c,:)];
                        else
                            table_to_restock = [table_to_restock; c, ...
				fridges_range_for_charging_RT(c,:)];
                        end
                    end
                    
                    if length(table_to_restock) > 1

                        [~,t] = min(table_to_restock(:,2));
                        n = table_to_restock(t,1);

                        % heat from cooling (power demand) for one more minute
			transitional_storage_power_for_one_more_minute = ...
				fridges_range_for_charging_RT(n,7) * ...
				fridges_range_for_charging_RT(n,6);
                        % this request secures that the fridge do not overload
			if fridges_range_for_charging_RT(n,9) - ...
				(fridges_range_for_charging_RT(n,6) * ...
				time_step) < 0
                            %
                            fridges_range_for_charging_RT(n,9) = 0;
                        else
                            % save the time period that was integrated
			    fridges_range_for_charging_RT(n, 1) = ...
				fridges_range_for_charging_RT(n, 1) + ...
				fridges_range_for_charging_RT(n, 7);
                            
                            % update residual_capacity
			    fridges_range_for_charging_RT(n, 9) = ...
				fridges_range_for_charging_RT(n, 9) - ...
				time_step * fridges_range_for_charging_RT(n,6);
                            % update power_for_load
			    power_for_load = power_for_load - ...
			    (transitional_storage_power_for_one_more_minute / ...
			    fridges_range_for_charging_RT(n, 8) / 3.6e6) * ...
			    buses(fridges_range_for_charging_RT(n, 2)). ...
			    supermarkets(fridges_range_for_charging_RT(n, 3)). ...
			    supermarket_number_scale * ...
			    buses(fridges_range_for_charging_RT(n, 2)). ...
			    supermarkets(fridges_range_for_charging_RT(n, 3)). ...
			    refrigerators(fridges_range_for_charging_RT(n,4)). ...
			    fridge_number_scale;
                            % update cooling
                            fridges_range_for_charging_RT(n, 5) = ...
				fridges_range_for_charging_RT(n,5) + ...
			        time_step * fridges_range_for_charging_RT(n,6);
                            % update of electric_power_consum
			    fridges_range_for_charging_RT(n,10) = ...
			    (fridges_range_for_charging_RT(n,5) / ...
			    fridges_range_for_charging_RT(n,8) / 3.6e6) * ...
			    buses(fridges_range_for_charging_RT(n, 2)). ...
			    supermarkets(fridges_range_for_charging_RT(n, 3)). ...
			    supermarket_number_scale * ...
			    buses(fridges_range_for_charging_RT(n, 2)). ...
			    supermarkets(fridges_range_for_charging_RT(n, 3)). ...
			    refrigerators(fridges_range_for_charging_RT(n,4)). ...
			    fridge_number_scale;

                            % intigrate_power update
			    fridges_range_for_charging_RT(n,11) = ...
				fridges_range_for_charging_RT(n,10);
                        end
                        
                    else
                            MODUS = 'do_not_load';
                    end
                else
                    for v = 1 : length(fridges_range_for_charging_RT(:,1))
                        if fridges_range_for_charging_RT(v,1) < 1
                            % estimates the rest of the time_crit to one hour
                            s = 1 - fridges_range_for_charging_RT(v,1);
                            % power cooling updated
			    fridges_range_for_charging_RT(v,5) = ...
			    fridges_range_for_charging_RT(v,5) + ...
			    s * fridges_range_for_charging_RT(v,6);
			    % update of electric_power_consumption
			    fridges_range_for_charging_RT(v,10) = ...
			    (fridges_range_for_charging_RT(v,5) / ...
			    fridges_range_for_charging_RT(v,8) / 3.6e6) * ...
			    buses(fridges_range_for_charging_RT(n, 2)). ...
			    supermarkets(fridges_range_for_charging_RT(n, 3)). ...
			    supermarket_number_scale * ...
			    buses(fridges_range_for_charging_RT(n, 2)). ...
			    supermarkets(fridges_range_for_charging_RT(n, 3)). ...
			    refrigerators(fridges_range_for_charging_RT(n,4)). ...
			    fridge_number_scale;
                        else
                            MODUS = 'do_not_load';
                        end
                    end
                    MODUS = 'do_not_load';
                end
            end
        end
        
        % this function estimates power_for_load_nett
        function [power_for_load, hourly_demand, power_b, power_promised] = ...
		power_for_load_nett(obj, ...
			count_number_steps, ...
			promised_gen_output_DA_gross, ...
			hourly_demand_day, ...
			hourly_demand_night)
            
            if count_number_steps < 9 || count_number_steps > 20
                hourly_demand = hourly_demand_night;
            else
                hourly_demand = hourly_demand_day;
            end
            if promised_gen_output_DA_gross > hourly_demand
                power_promised = hourly_demand;
		power_b = sum(gen_out_day_A) - hourly_demand;
            else
                power_promised = promised_gen_output_DA_gross;
		power_b = sum(gen_out_day_A) - promised_gen_output_DA_gross;
            end
            if sum(gen_out_day_T) > sum(power_b)
		power_for_load = sum(gen_out_day_T) - sum(power_b) + ...
			hourly_demand - power_promised;
	    else
                power_for_load = hourly_demand - power_promised;
            end
            
        end
    end
end
