% Generating cabinets and rooms (from both legacy and new domains)
{ cabinet(C) : cabinetDomainNew(C); cabinet(C) : legacyConfig(cabinet(C)) }.
{ room(R) : roomDomainNew(R); room(R) : legacyConfig(room(R)) }.

% Assign each cabinet to either be small or high
1 { cabinetSmall(C); cabinetHigh(C) } 1 :- cabinet(C).

% Assign each thing to a single cabinet (ensure each thing is placed in one cabinet)
1 { cabinetTOthing(C,T) : cabinet(C) } 1 :- legacyConfig(thing(T)).

% Assign cabinets to rooms (ensure each cabinet is placed in exactly one room)
1 { roomTOcabinet(R,C) : room(R) } 1 :- cabinet(C).

% Establish ownership relationships between persons and their things
person(P) :- legacyConfig(person(P)).
thing(T) :- legacyConfig(thing(T)).
owns(P,T) :- legacyConfig(personTOthing(P,T)).

% Ensure that every person is assigned to one room
1 { personTOroom(P,R) : room(R) } 1 :- legacyConfig(person(P)).

% Define short things (those that are not long)
thingShort(T) :- legacyConfig(thing(T)), not thingLong(T).

% Constraints for configuration:

% Long things must go into high cabinets
:- thingLong(T), cabinetTOthing(C,T), not cabinetHigh(C).

% Short things should prefer small cabinets, but avoid high cabinets
preferSmall(T) :- thingShort(T).
:- preferSmall(T), cabinetTOthing(C,T), cabinetHigh(C).

% Limit of 5 things per cabinet
:- cabinetTOthing(C,T1), cabinetTOthing(C,T2), T1 != T2, #count { T : cabinetTOthing(C,T) } > 5.

% Prevent assigning things belonging to different people to the same cabinet
:- cabinetTOthing(C,T1), cabinetTOthing(C,T2), owns(P1,T1), owns(P2,T2), P1 != P2.

% Room capacity constraint: each room can hold up to 4 cabinets, with small and high cabinet slots counted differently
:- roomTOcabinet(R,C1), roomTOcabinet(R,C2), C1 != C2,
   #sum { 1,C : roomTOcabinet(R,C), cabinetSmall(C);
          2,C : roomTOcabinet(R,C), cabinetHigh(C) } > 4.

% Encourage cabinet 23 to be small if used
:- cabinet(23), not cabinetSmall(23), preferSmall(_).

% Legacy configuration data
legacyConfig(person(1)).
legacyConfig(person(2)).
legacyConfig(thing(3)).
legacyConfig(thing(4)).
legacyConfig(thing(5)).
legacyConfig(thing(6)).
legacyConfig(thing(7)).
legacyConfig(thing(8)).
legacyConfig(thing(21)).
legacyConfig(personTOthing(1,3)).
legacyConfig(personTOthing(1,4)).
legacyConfig(personTOthing(1,5)).
legacyConfig(personTOthing(1,6)).
legacyConfig(personTOthing(1,7)).
legacyConfig(personTOthing(1,21)).
legacyConfig(personTOthing(2,8)).

legacyConfig(room(15)).
legacyConfig(roomTOcabinet(15,9)).
legacyConfig(room(16)).
legacyConfig(roomTOcabinet(16,10)).

legacyConfig(cabinet(9)).
legacyConfig(cabinetTOthing(9,3)).
legacyConfig(cabinetTOthing(9,4)).
legacyConfig(cabinetTOthing(9,5)).
legacyConfig(cabinetTOthing(9,6)).
legacyConfig(cabinetTOthing(9,7)).

legacyConfig(cabinet(10)).
legacyConfig(cabinetTOthing(10,8)).

% Define long things
thingLong(3).
thingLong(8).
thingLong(21).

% New cabinet and room domains
cabinetDomainNew(22..23).
roomDomainNew(17..20).

% Cost definitions for reuse, removal, and creation
reuseCabinetTOthingCost(0).
reuseRoomTOcabinetCost(0).
reusePersonTOroomCost(0).
reuseCabinetAsHighCost(3).
reuseCabinetAsSmallCost(0).
reuseRoomCost(0).
removeCabinetTOthingCost(2).
removeRoomTOcabinetCost(2).
removePersonTOroomCost(2).
removeCabinetCost(2).
removeRoomCost(2).
cabinetHighCost(100).
cabinetSmallCost(10).
roomCost(5).

% Optimization: Minimize creation, reuse, and removal costs
#minimize {
    3 @ C : cabinet(C), not legacyConfig(cabinet(C)), cabinetHigh(C);            % Adding new high cabinets
    0 @ C : cabinet(C), legacyConfig(cabinet(C)), not cabinetHigh(C);            % Reusing legacy high cabinets
    3 @ C : cabinet(C), not legacyConfig(cabinet(C)), cabinetSmall(C);           % Adding new small cabinets
    0 @ C : cabinet(C), legacyConfig(cabinet(C)), not cabinetSmall(C);           % Reusing legacy small cabinets
    2 @ C, T : cabinetTOthing(C,T), not legacyConfig(cabinetTOthing(C,T));       % Adding new thing-to-cabinet assignments
    2 @ R, C : roomTOcabinet(R,C), not legacyConfig(roomTOcabinet(R,C));         % Assigning new room-to-cabinet mappings
    2 @ P, R : personTOroom(P,R), not legacyConfig(personTOroom(P,R));           % Assigning new person-to-room mappings
    2 @ C : removeCabinetCost(C), not legacyConfig(cabinet(C));                  % Removing unused cabinets
    2 @ R : removeRoomCost(R), not legacyConfig(room(R));                        % Removing unused rooms
    100 @ C : cabinetHighCost(C), not legacyConfig(cabinet(C)), cabinetHigh(C);  % High cabinet creation cost
    10 @ C : cabinetSmallCost(C), not legacyConfig(cabinet(C)), cabinetSmall(C); % Small cabinet creation cost
    5 @ R : roomCost(R), not legacyConfig(room(R))                               % Room creation cost
}.

% Output the solution
#show cabinet/1.
#show cabinetSmall/1.
#show cabinetHigh/1.
#show room/1.
#show cabinetTOthing/2.
#show roomTOcabinet/2.
