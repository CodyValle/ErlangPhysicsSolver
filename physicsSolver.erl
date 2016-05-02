-module(physicsSolver).

-export([solve/1]).
-export([circular/1]).

-export([force_grav/3]).
-export([force_grav/1]).



-export([get_from/2]).
-export([convert/2]).

% This module assumes are values are in base SI units. 
% The convert function is available for conversion if necessary.

% The single entry point for solving one-dimensional physics equations.
% Three data points (acceleration, distance, time, velocityi, or velocityf) must be given.
% The data points must be a tuple with its type and value, in a list in any order.
% Example: 
%  solve([{distance, 2},{acceleration, 3.5},{velocityi, -4.8}]).
% The other two values will be returned in a similar list.
% Note: one type of velocity must be present in the list of three data points. 
% Note: sometimes two times are returned (time1 and time2) due to the quadratic formula.
solve(L) -> filter(lists:keysort(1, L)).

% Filters which three data points are available, and calls the appropriate function to calculate the unknown data points.
filter([{acceleration, _}, {distance, _}, {time, _}|_]) -> io:fwrite("Velocity data point is not present in the sorted list of three.");
filter([{acceleration, A}, {distance, D}, {velocityf, V}|_]) -> adv2(A,D,V);
filter([{acceleration, A}, {distance, D}, {velocityi, V}|_]) -> adv1(A,D,V);
filter([{acceleration, A}, {time, T}, {velocityf, V}|_]) -> atv2(A,T,V);
filter([{acceleration, A}, {time, T}, {velocityi, V}|_]) -> atv1(A,T,V);
filter([{acceleration, A}, {velocityf, V2}, {velocityi, V1}|_]) -> av2v1(A,V2,V1);
filter([{distance, D}, {time, T}, {velocityf, V}|_]) -> dtv2(D,T,V);
filter([{distance, D}, {time, T}, {velocityi, V}|_]) -> dtv1(D,T,V);
filter([{distance, D}, {velocityf, V2}, {velocityi, V1}|_]) -> dv2v1(D,V1,V2);
filter([{time, T}, {velocityf, V2}, {velocityi, V1}|_]) -> tv2v1(T,V1,V2);
filter(_) -> io:fwrite("Unknown token.").

% Collection of functions named after the three data points they use to calculate the two unknown ones.
adv2(A,D,V) -> [{time1, (V - math:sqrt(V * V - 2 * A * D)) / A},{time2, (V + math:sqrt(V * V - 2 * A * D)) / A},{velocityi, math:sqrt(V * V - 2 * A * D)}].
adv1(A,D,V) -> [{time1, -(V + math:sqrt(V * V + 2 * D * A)) / A}, {time2, (-V + math:sqrt(V * V + 2 * D * A)) / A}, {velocityf, math:sqrt(V * V + 2 * A * D)}].
atv2(A,T,V) -> [{distance, V * T - A * T * T / 2},{velocityi, V - A * T}].
atv1(A,T,V) -> [{distance, V * T + A * T * T / 2}, {velocityf, A * T + V}].
av2v1(A,V2,V1) -> [{time, (V2 - V1) / A}, {distance, (V2 * V2 - V1 * V1) / (2 * A)}].
dtv2(D,T,V) -> [{acceleration, 2 * (V * T - D) / T / T},{velocityi, V - 2 * D / T}].
dtv1(D,T,V) -> [{acceleration, 2 * (D - V * T) / T / T}, {velocityf, 2 * D * T - V}].
dv2v1(D,V1,V2) -> [{acceleration, (V2 * V2 - V1 * V1) / 2 / D},{time, (2 * D) / (V2 + V1)}].
tv2v1(T,V1,V2) -> [{acceleration, (V2 - V1) / T}, {distance, (V2 + V1) * T / 2}].

% Circular function entry point
circular(L) -> filter_circular(lists:keysort(1, L)).

% Circular filter
filter_circular([{acceleration, A},{mass, M}|_]) -> am(A,M);
filter_circular([{force, F},{mass, M}|_]) -> fm(F,M);
filter_circular([{mass, M},{radius, R},{velocity, V}|_]) -> mrv(M,R,V);
filter_circular([{mass, M},{radius, R},{time, T}|_]) -> mrt(M,R,T);
filter_circular([{radius, R},{time, T}|_]) -> rt(R,T);
filter_circular([{radius, R},{velocity, V}|_]) -> rv(R,V);
filter_circular([{acceleration, _},{force, _}|_]) -> io:fwrite("Don't know what to do with this junk.").

% Circular calculations
am(A,M) -> [{force, M * A}].
fm(F,M) -> [{acceleration, (F / M)}].
mrv(M,R,V) -> [{force, M * (V * V) / R}].
mrt(M,R,T) -> [{force, M * (4 * (math:pi() * math:pi()) * R) / (T * T)}].
rt(R,T) -> [{velocity, (2*math:pi()*R) / T}, {acceleration, (4 * (math:pi() * math:pi()) * R) / (T * T)}].
rv(R,V) -> [{acceleration, (V * V) / R}].


% Returns the force of gravity
force_grav(M1,M2,D) -> (6.673e-11 * M1 * M2) / (D * D).
force_grav(M) -> M * 9.8.




% Extracts the data value from a list of tuples.
% get_from(label, [{label, 23}, {...}, ...]). returns 23.
get_from(Y, [{Y, X} | _]) -> X;
get_from(Y, [_ | T]) -> get_from(Y, T).

% Suite of conversions
convert(T, yr) -> convert(T * 365, day);
convert(T, month) -> convert(T * 30, day);
convert(T, week) -> convert(T * 7, day);
convert(T, day) -> convert(T * 24, hr);
convert(T, hr) -> convert(T * 60, min);
convert(T, min) -> convert(T * 60, sec);
convert(T, sec) -> {sec, T};
convert(T, ms) -> convert(T / 1000, sec);
convert(T, us) -> convert(T / 1000, ms);
convert(T, ns) -> convert(T / 1000, us);

convert(D, mile) -> convert(D * 1760, yard);
convert(D, yard) -> convert(D * 0.9144, meter);
convert(D, feet) -> convert(D / 3, yard);
convert(D, inch) -> convert(D / 12, feet);

convert(D, kilo) -> convert(D * 1000, meter);
convert(D, meter) -> {meter, D};
convert(D, deci) -> convert(D / 10, meter);
convert(D, centi) -> convert(D / 10, deci);
convert(D, milli) -> convert(D / 10, centi);
convert(D, micro) -> convert(D / 1000, milli);
convert(D, nano) -> convert(D / 1000, micro);

convert(A, degrees) -> {radians, math:cos(A * math:pi() / 180)}.