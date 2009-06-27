#!/usr/bin/swipl -q -f
/* Developed against SWI-Prolog:
 *     http://www.swi-prolog.org/
 *     aptitude install swi-prolog
 * Runnable as-is.
 */
/* Problem 12: What is the value of the first triangle number to have over
 * five hundred divisors?
 *
 * The sequence of triangle numbers is generated by adding the natural
 * numbers. So the 7^(th) triangle number would be 1 + 2 + 3 + 4 + 5 + 6 + 7
 * = 28. The first ten terms would be:
 *
 * 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, ...
 *
 * Let us list the factors of the first seven triangle numbers:
 *
 *      1: 1
 *      3: 1,3
 *      6: 1,2,3,6
 *     10: 1,2,5,10
 *     15: 1,3,5,15
 *     21: 1,3,7,21
 *     28: 1,2,4,7,14,28
 *
 * We can see that 28 is the first triangle number to have over five divisors.
 *
 * What is the value of the first triangle number to have over five hundred
 * divisors?
 */

prolog :-
    first_triangle_with_divisors(T, 500),
    print(T),
    print('\n'),
    halt.

/*** triangle ***/
/* Asserts that Tn is the Nth triangular number */
triangle(N, Tn) :- Tn is N * (N + 1) / 2.

/*** num_divisors(N, DivisorCount) ***/
/* Asserts that N has DivisorCount divisors. */
/* Recurses over possible divisors from N down to 1 using _step. */
/* OPTIMIZATION:
 * Each step counts a divisor and then recurses with the next lower number.
 * However!  Every divisor X below sqrt(N) has a corresponding divisor Y
 * greater than sqrt(N) such that X * Y == N.  So we only need to test sqrt(N)
 * and below, then double it.
 * However!  If N is a perfect square, we will be counting its square root
 * twice here -- so then decrement the final count by one.
 */
num_divisors(N, DivisorCount) :-
    /* Perfect square */
    FirstDivisor is floor(N ** 0.5),
    N =:= FirstDivisor ** 2,
    num_divisors_step(N, FirstDivisor, PartialCount, 0),
    DivisorCount is PartialCount * 2 - 1.

num_divisors(N, DivisorCount) :-
    /* Not a square */
    FirstDivisor is floor(N ** 0.5),
    N > FirstDivisor ** 2,
    num_divisors_step(N, FirstDivisor, PartialCount, 0),
    DivisorCount is PartialCount * 2.

/** num_divisors_step(N, Divisor, DivisorCount, RunningCount **/
/* Asserts that N has DivisorCount divisors less than or equal to Divisor.
 * RunningCount is the number of divisors greater than some starting divisor
 * and is used for intermediate state.
 */
num_divisors_step(_, 1, TotalCount, RunningCount) :-
    /* 1 is always a divisor; bump the total and stop recursing */
    TotalCount is RunningCount + 1.

num_divisors_step(N, D, TotalCount, RunningCount) :-
    /* D is a divisor; bump the total and recurse */
    D > 1,
    N mod D =:= 0,
    NewRunningCount is RunningCount + 1,
    NextD is D - 1,
    num_divisors_step(N, NextD, TotalCount, NewRunningCount).

num_divisors_step(N, D, TotalCount, RunningCount) :-
    /* D is NOT a divisor; preserve the total and recurse */
    D > 1,
    N mod D > 0,
    NextD is D - 1,
    num_divisors_step(N, NextD, TotalCount, RunningCount).

/*** first_triangle_with_divisors(Tn, D) ***/
/* The heart of the matter.  Asserts that Tn is the first triangular number
 * with at least D divisors.
 */
/* Uses _step to recurse upwards from 1. */
first_triangle_with_divisors(Tn, D) :-
    first_triangle_with_divisors_step(Tn, D, 1).

/** first_triangle_with_divisors_step(Tn, D, NAttempt) **/
/* Asserts that Tn is the first triangular number with at least D divisors,
 * starting with the NAttempt-th triangular number.
 */
/* Uses _test to decide whether to recurse. */
first_triangle_with_divisors_step(Tn, D, NAttempt) :-
    triangle_divisors(NAttempt, TDivisors),
    first_triangle_with_divisors_test(Tn, D, NAttempt, TDivisors).

first_triangle_with_divisors_test(Tn, D, NAttempt, TDivisors) :-
    /* Success; compute triangle and succeed */
    TDivisors > D,
    triangle(NAttempt, Tn).

first_triangle_with_divisors_test(Tn, D, NAttempt, TDivisors) :-
    /* Failure; try again with the next triangular number */
    TDivisors =< D,
    NextAttempt is NAttempt + 1,
    first_triangle_with_divisors_step(Tn, D, NextAttempt).

/*** triangle_divisors ***/
/* Asserts that the Nth triangular number has D divisors */
/* Rationale: the triangle formula is n * (n + 1) / 2.  We know n is an
 * integer.  Thus either n or n + 1 is even.  This leaves two cases:
 * 1. n is even, so Tn has factors n/2 and n + 1.
 * 2. n is odd, so Tn has factors n and (n + 1)/2.
 * Any two consecutive numbers must be coprime, so both pairs of factors
 * above must also be coprime.  Thus the divisors of Tn consist of the cross
 * join of the divisors of its two factors above.
 * In short, find the number of divisors of each and multiply.
 */
triangle_divisors(N, D) :-
    /* N is even; use N/2 and N + 1 */
    N mod 2 =:= 0,
    N1 is N / 2,
    N2 is N + 1,
    num_divisors(N1, D1),
    num_divisors(N2, D2),
    D is D1 * D2.

triangle_divisors(N, D) :-
    /* N is odd; use N and (N + 1)/2 */
    N mod 2 =:= 1,
    N1 is N,
    N2 is (N + 1) / 2,
    num_divisors(N1, D1),
    num_divisors(N2, D2),
    D is D1 * D2.
