% =========================================================
% ARTI 401 - Lab 9: IO Stream and Database Manipulation
% Lab Activity - The "Name Game"
%
% Run with:   ?- name_game.
% Type each answer and press Enter (no full stop needed).
% =========================================================

:- use_module(library(readutil)).

% The current set of letters is stored in the database,
% so it must be declared dynamic to be changed at runtime.
:- dynamic letter/1.

% ---------------------------------------------------------
% Start of the game
% ---------------------------------------------------------
name_game :-
    retractall(letter(_)),            % start fresh every game
    assertz(letter(a)),               % the given set of letters
    assertz(letter(b)),
    assertz(letter(c)),
    nl,
    write('Hi, This is the "Name Game".'), nl,
    write('You will be given a set of English letters in which you will add, delete or move to create your name.'), nl,
    menu_loop.

% ---------------------------------------------------------
% Menu loop: show menu, read choice, act, repeat until Exit
% ---------------------------------------------------------
menu_loop :-
    show_menu,
    read_input(Input),
    handle(Input, Next),
    (   Next == stop
    ->  true
    ;   menu_loop
    ).

show_menu :-
    nl,
    write('Choose from the following:'), nl,
    write('1- Display the current set of letters'), nl,
    write('2- Add a letter'), nl,
    write('3- Add a letter at the top'), nl,
    write('4- Add a letter at the bottom'), nl,
    write('5- Delete a letter'), nl,
    write('6- Delete all letters'), nl,
    write('7- Exit'), nl,
    write('Enter your choice....'), nl.

% handle(Choice, Next): Next is 'go' (keep playing) or 'stop'
handle('1', go) :- !, display_letters.
handle('2', go) :- !, add_letter(assert,  'added').
handle('3', go) :- !, add_letter(asserta, 'added at the top').
handle('4', go) :- !, add_letter(assertz, 'added at the bottom').
handle('5', go) :- !, delete_letter.
handle('6', go) :- !, retractall(letter(_)), write('All letters deleted.'), nl.
handle('7', stop) :- !, write('Goodbye!'), nl.
handle(end_of_file, stop) :- !.
handle(_, go) :-
    write('Invalid choice, please enter a number from 1 to 7.'), nl.

% ---------------------------------------------------------
% 1 - Display the current set of letters
% ---------------------------------------------------------
display_letters :-
    findall(L, letter(L), Letters),
    (   Letters == []
    ->  write('The set of letters is empty.'), nl
    ;   atomic_list_concat(Letters, ' ', Text),
        write('Current set of letters: '), write(Text), nl
    ).

% ---------------------------------------------------------
% 2, 3, 4 - Add a letter (assert / asserta / assertz)
% ---------------------------------------------------------
add_letter(How, Message) :-
    write('Enter the letter to add:'), nl,
    read_input(L),
    (   valid_letter(L)
    ->  Clause =.. [How, letter(L)],
        call(Clause),
        write('Letter '), write(L), write(' '), write(Message), write('.'), nl
    ;   write('Please enter a single English letter.'), nl
    ).

% ---------------------------------------------------------
% 5 - Delete a letter (retract removes the first match)
% ---------------------------------------------------------
delete_letter :-
    write('Enter the letter to delete:'), nl,
    read_input(L),
    (   valid_letter(L)
    ->  (   retract(letter(L))
        ->  write('Letter '), write(L), write(' deleted.'), nl
        ;   write('Letter '), write(L), write(' is not in the set.'), nl
        )
    ;   write('Please enter a single English letter.'), nl
    ).

% ---------------------------------------------------------
% Helpers
% ---------------------------------------------------------

% A valid letter is one character: A-Z or a-z
valid_letter(L) :-
    atom(L),
    atom_length(L, 1),
    char_code(L, Code),
    (   Code >= 65, Code =< 90
    ;   Code >= 97, Code =< 122
    ),
    !.

% Reads one line from the user and returns it as a trimmed atom.
% Empty lines are skipped. At end of input it returns end_of_file.
read_input(Input) :-
    write('|: '), flush_output,
    read_line_to_string(user_input, Raw),
    (   Raw == end_of_file
    ->  Input = end_of_file
    ;   normalize_space(atom(Atom), Raw),
        (   Atom == ''
        ->  read_input(Input)
        ;   Input = Atom
        )
    ).
