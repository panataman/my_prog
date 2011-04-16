NK_KT_S = { ...
    1, ... % the number decides which kind of fridge is installed one means plug in fridge or two combine fridge
    2, ... % epsilon
    [200 200]... % masse_stored
    [2.3 3.52], ... % specific_mass_capacity
    4.7e3, ... % energy consumption per day Wh/24h
    -6, ... % temperature_min in C°
    2, ... % temperature_max in C°
    2, ... % number_of_walls
    [16.4 6.7], ... % area_wall
    [0.38 0.38], ... % heat_transmission_coefficient
    [19 15], ... % temperature_outside
    0, ... % refrigerating capacity
    0.66, ... % compressor quotient
    1, ... % averaged cooling room temperature in C°
    0}; % cooling power in W

TK_TKT_S = { ...
    1, ... % the number decides which kind of fridge is installed one means plug in fridge or two combine fridge
    1.5, ... % epsilon
    [480 840 360 756]... % masse_stored
    [1.76 1.76 1.38 2.62], ... % specific_mass_capacity
    7.4e3, ... % energy consumption per day Wh/24h
    -25, ... % temperature_min in C°
    -18, ... % temperature_max in C°
    2, ... % number_of_walls
    [36.9 16.8] ... % area_wall
    [0.38 0.38], ... % heat_transmission_coefficient
    [19 15], ... % temperature_outside
    0, ... % refrigerating capacity
    0.66, ... % compressor quotient
    -19, ... % averaged cooling room temperature in C°
    0}; % cooling power in W

NK_KR_V = { ...
    2, ... % the number decides which kind of fridge is installed one means plug in fridge or two combine fridge
    2, ... % epsilon
    [1210 1050 2520], ... % masse_stored
    [2.51 2.3 3.85], ... % specific_mass_capacity
    0, ... % energy consumption per day Wh/24h
    0, ... % temperature_min in C°
    10, ... % temperature_max in C°
    4, ... % number_of_walls
    [40.2 68.8 24.3], ... % area_wall
    [1.53 0.62 0.38], ... % heat_transmission_coefficient
    [19 19 15], ... % temperature_outside
    0, ... % refrigerating capacity
    0, ... % compressor quotient
    5, ... % averaged cooling room temperature in C°
    28e3}; % cooling power in W

