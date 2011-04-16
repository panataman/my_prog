classdef New_cooling_strategy < handle
    % NEW_COOLING_STRATEGY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function obj = New_cooling_strategy
        end % function constructor
        
        function [fridges_range_for_charging_RT, hourly_demand_out] = strategy_calculator( ...
	        obj, busses, hourly_demand_day, hourly_demand_night, count_number_days, count_number_steps, operating_gen_output_RT_brutto, ...
		prommised_gen_output_DA_brutto, operating_gen_output_RT, number_steps, number_days, diff_RT_DA)

            % This function gives a matrix which contains rang of
            % refrigerators refer to size up time to the critical temperature
            heat_from_cooling = 0;
            count_bus = 0;
            time_step = 1/60;
            electric_power_consum = 0;
            wind_power_intigrated = 0;
            fridges_range_for_charging_RT = zeros(1,12);
            
            for s = 1:length(busses)

                count_bus = count_bus + 1;
                count_supermarket = 0;

                for i = 1 : length(busses(s).number_supermarkets)

                    count_supermarket = count_supermarket + 1;
                    count_refrigerator = 0;

                    for j = 1:length([busses(s).supermarkets(i).refrigerators])

                        % before the estimation of temperature for the next step can be
                        % startet, the dessition for the power, which will be adjudged
                        % for each fridge, has be falled
                        [Q_losses, Q_losses_max, time_to_T_critical_max] = busses(s).supermarkets(i).refrigerators(j).sum_all_losses(...
			    number_steps, count_number_steps, count_number_days, number_days);
                        
                        % this function estimates the heat power the fridge can maximum intigrate for the moment
                        resid_capacity = busses(s).supermarkets(i).refrigerators(j).estimator_full_heat_capacity(count_number_steps, ...
                            count_number_days, Q_losses);
                        
                        if sum (fridges_range_for_charging_RT) == 0 % securing
                            
                            count_refrigerator = count_refrigerator + 1;
                            fridges_range_for_charging_RT = [...
                                time_to_T_critical_max ...
                                busses(s).supermarkets(i). ...
                                refrigerators(j). ...
                                current_temperature_capacity(count_number_steps, ...
                                count_number_days) ...
                                count_bus ...
                                count_supermarket ...
                                count_refrigerator ...
                                heat_from_cooling ...
                                Q_losses ...
                                time_step ...
                                busses(s).supermarkets(i).refrigerators(j). ...
                                epsilon ...
                                resid_capacity ...
                                electric_power_consum ...
                                wind_power_intigrated ...
                                ];
                            
                        else
                            
                            count_refrigerator = count_refrigerator + 1;
                            fridges_range_for_charging_RT = [...
                                fridges_range_for_charging_RT; ...
                                time_to_T_critical_max ...                      %1
                                busses(s).supermarkets(i).refrigerators(j).current_temperature_capacity(count_number_steps, count_number_days) ...		%2
                                count_bus ...                                   %3
                                count_supermarket ...                           %4
                                count_refrigerator ...                          %5
                                heat_from_cooling ...                           %6
                                Q_losses ...                                    %7
                                time_step ...                                   %8
                                busses(s).supermarkets(i).refrigerators(j).epsilon ... %9
                                resid_capacity ...                              %10
                                electric_power_consum ...                       %11
                                wind_power_intigrated ...                       %12
                                ];
                            
                        end
                    end
                end
            end
            
            % condition for load fridges
            MODUS = 'load';
            
            
            [power_for_load, hourly_demand] = obj.power_for_load_netto(count_number_steps, count_number_days, ...
                prommised_gen_output_DA_brutto, operating_gen_output_RT_brutto, operating_gen_output_RT, diff_RT_DA, ...
                hourly_demand_day, hourly_demand_night);
            hourly_demand_out = hourly_demand;
            duffi = power_for_load;
            % the the electric power real time and the electric power day ahead
            % will be compared and subsequently distributed
            while strcmp('load', MODUS)
                
                table_to_restock = 0;
                
                %disp('********* WHILE ************')
                %fprintf('\nPower for load wird verteilt: %f\n', power_for_load)
                
                if power_for_load > 0
                    
                    %disp('********* POWER FOR LOAD OK ************')
                    % here the conditions of the time to critical temperature will be found and prooved
                    for j = find(fridges_range_for_charging_RT(:,10) > 0)
                        
                        if table_to_restock(1) == 0
                            
                            table_to_restock = [j, fridges_range_for_charging_RT(j,:)];
                            
                        else
                            
                            table_to_restock = [table_to_restock; j, fridges_range_for_charging_RT(j,:)];
                            
                        end
                    end
                    
                    if length(table_to_restock) > 1
                        [~,j] = min(table_to_restock(:,2));
                        i = table_to_restock(j,1);

                        % heat from cooling (power demand) for one more minute
                        transitional_storage_power_for_one_more_minute = fridges_range_for_charging_RT(i,8) * fridges_range_for_charging_RT(i,7);
                        
                        
                         if i == 2 && count_number_days == 1 && (count_number_steps == 18 || count_number_steps == 19)
                             fprintf('\nRESID_CAPACITY: %f',fridges_range_for_charging_RT(i,10)-fridges_range_for_charging_RT(i,7))
                             fprintf('\nPOWER FOR MINUTE: %f\n',fridges_range_for_charging_RT(i,7)*time_step)
                         end
                        
                        
                        % this request secures that the fridge do not overload
                        if fridges_range_for_charging_RT(i,10) - (fridges_range_for_charging_RT(i,7)  * ...                               
                            time_step)  < 0
                            %
                            fridges_range_for_charging_RT(i,10) = 0;
                            
                            if i == 2 && count_number_days == 1 && (count_number_steps == 18 || count_number_steps == 19)
                                disp('************* CAPACITY CHECK FAILD ************')
                                fprintf('\nRESID_CAPACITY: %f',fridges_range_for_charging_RT(i,10)-fridges_range_for_charging_RT(i,7))
                                fprintf('\nPOWER FOR MINUTE: %f\n',fridges_range_for_charging_RT(i,7)*time_step)
                                fprintf('\nCOUNT NUMBER STEPS: %f\n', count_number_steps)
                            end
                            
                        else
                            
                            if i == 2 && count_number_days == 1 && (count_number_steps == 18 || count_number_steps == 19)
                                disp('************* CAPACITY CHECK OK ************')
                                fprintf('\nRESID_CAPACITY: %f',fridges_range_for_charging_RT(i,10)-fridges_range_for_charging_RT(i,7)*time_step)
                                fprintf('\nFRIDGE: %f',fridges_range_for_charging_RT(i,5))
                                fprintf('\ntime_crit: %f\n',fridges_range_for_charging_RT(i,1))
                                fprintf('Q_losses: %f\n',fridges_range_for_charging_RT(i,7))
                            end
                            % save the time period that was intigrated
                            fridges_range_for_charging_RT(i, 1) = ...
                                fridges_range_for_charging_RT(i, 1) + fridges_range_for_charging_RT(i,8) ;
                            
                            % update resid_capacity
                            fridges_range_for_charging_RT(i, 10) = fridges_range_for_charging_RT(i, ...
                                10) - time_step * fridges_range_for_charging_RT(i,7) ;
                            
                            % update power_for_load
                            power_for_load = power_for_load - (transitional_storage_power_for_one_more_minute / ...
                                fridges_range_for_charging_RT(i, 9) / 3.6e6) * busses(fridges_range_for_charging_RT( ...
                                i, 3)).number_supermarkets(fridges_range_for_charging_RT(i, 4));
                            
                            % update heat_from_cooling
                            fridges_range_for_charging_RT(i, 6) = fridges_range_for_charging_RT(i,6) + ...
			        time_step * fridges_range_for_charging_RT(i,7);
                            
                            
                            % update of electric_power_consum
                            fridges_range_for_charging_RT(i,11) = (fridges_range_for_charging_RT(i,6) / ...
                                fridges_range_for_charging_RT(i, 9) / 3.6e6) * busses(fridges_range_for_charging_RT( ...
                                i, 3)).number_supermarkets(fridges_range_for_charging_RT(i, 4));
                            
                            % intigrate_power update
                            fridges_range_for_charging_RT(i,12) = fridges_range_for_charging_RT(i,11);
                            if i == 2 && count_number_days == 1 && (count_number_steps == 18 || count_number_steps == 19)
                                fprintf('cooling: %f\n',fridges_range_for_charging_RT(i,6))
                                fprintf('\nCOUNT NUMBER STEPS: %f\n', count_number_steps)
                            end
                        end
                        
                    else
			    disp('modus1')
                            MODUS = 'do_not_load';
                    end
                else
                    
                    for i = 1 : length(fridges_range_for_charging_RT(:,1))
                        
                        if fridges_range_for_charging_RT(i,1) < 1

                            % estimates the rest of the time_crit to one hour
                            s = 1 - fridges_range_for_charging_RT(i,1);

                            if i == 2 && count_number_days == 1 && (count_number_steps == 18 || count_number_steps == 19 )
                                disp('************* POWER FOR LOAD CHECK FAILD ************')
                                fprintf('\ntime_crit: %f',fridges_range_for_charging_RT(i,1))
                                fprintf('\ns: %f\n',s)
                            end
                            
                            % power heat_from_cooling updated
                            fridges_range_for_charging_RT(i,6) = fridges_range_for_charging_RT(i,6) + s * fridges_range_for_charging_RT(i,7);
                            if i == 2 && count_number_days == 1 && (count_number_steps == 18 || count_number_steps == 19 )
                                fprintf('\nQ_cool: %f\n',fridges_range_for_charging_RT(i,6))
                            end
                            
                            % update of electric_power_consum
                            fridges_range_for_charging_RT(i,11) = (fridges_range_for_charging_RT(i,6) / ...
                                fridges_range_for_charging_RT(i, 9) / 3.6e6) * busses(fridges_range_for_charging_RT( ...
                                i, 3)).number_supermarkets(fridges_range_for_charging_RT(i, 4));
                            
                        else
                            disp('modus2')
                            MODUS = 'do_not_load';
                        end
                        
                        
                    end
                    disp('modus2')
                    MODUS = 'do_not_load';
                    
                end
            end
        end
        
        % this function estimates power_for_load_netto
        function [power_for_load, hourly_demand] = power_for_load_netto(obj, count_number_steps, count_number_days, ...
                prommised_gen_output_DA_brutto, operating_gen_output_RT_brutto, operating_gen_output_RT, diff_RT_DA, ...
                hourly_demand_day, hourly_demand_night)
            
            if count_number_steps < 9 || count_number_steps > 20
                
                hourly_demand = hourly_demand_night;
                
            else
                
                hourly_demand = hourly_demand_day;
                
            end
            %fprintf('\nprommised_gen_output_DA_brutto: %f\n', prommised_gen_output_DA_brutto)
            
            if prommised_gen_output_DA_brutto > hourly_demand
                
                power_prommised = hourly_demand;
                
            else
                
                power_prommised = prommised_gen_output_DA_brutto;
                
            end
            
            if  diff_RT_DA > 0
                
                power_for_load = operating_gen_output_RT + hourly_demand - power_prommised;
                
            else
                
                power_for_load = hourly_demand - power_prommised;
                
            end
            
        end
    end
end
