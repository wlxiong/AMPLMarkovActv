# Title: Constrained Optimization Approaches for Estimation of Structural Models
# Authors: Che-Lin Su and Kenneth L. Judd, November 2010
# Updated by Xiong Yiliang <wlxiong@gmail.com>

# Go to the NEOS Server (google "NEOS Server for Optimization").
# Click on "NEOS Solvers" and then go to "Nonlinearly Constrained Optimization"
# You can use any of the constrained optimization solvers that take AMPL input. 
# In the paper, we use the solver KNITRO.

# AMPL Model File:   MarkovActvDP.mod
# AMPL Data File:    MarkovActvDP.dat
# AMPL Command File: MarkovActvDP.run


# SET UP THE MODEL and DATA #

#  Define and process the data
param T;				# the equivalent minutes of a time slice
param H;                # number of time slice in the data
set TIME := 0..(H-1);   # TIME is the vector of time slices
param N;                # number of individuals in the data
set PERS := 1..N;       # PERS is the index set of individuals
param M;                # number of out-of-home activities
set ACTV := 1..M;       # ACTV is the index set of activities, in-home activity = 1
/*param HOME symbolic;    # HOME is a special activity*/

# Travel time
/*param travelTime {TIME cross ACTV cross ACTV};*/
param travelTime {ACTV cross ACTV};

# Define the state space used in the dynamic programming part
set TIMEACTV := TIME cross ACTV;
/*set TIMEHOME := TIME cross {HOME};*/
set X := TIMEACTV;	# X is the index set of states
set D := ACTV;

# Parameters and definition of transition process

# Define discount factor. We fix beta since it can't be identified.
param beta;      	 # discount factor

# END OF MODEL and DATA SETUP #

# Activity Parameters
var Um {ACTV};
var b {ACTV};
var c {ACTV};

# Define the ture parameters
param trueUm {ACTV};
param trueB {ACTV};
param trueC {ACTV};

# Temporal Activity Utility
var actvUtil {(t,j) in X} = Um[j]/3.141592653*( atan( ( t*T+T-b[j])/c[j]) - atan( ( t*T-b[j])/c[j]) );

# DEFINING STRUCTURAL PARAMETERS and ENDOGENOUS VARIABLES TO BE SOLVED #
# value of time
var valueOfTime >= 0;

# true VoT
param trueValueOfTime >= 0;

# transProb[i] defines transition probability that state in next time slice. 
/*var transProb {1..M} >= 0;*/

# Define variables for specifying initial parameter values
var initEV;

# DECLARE EQUILIBRIUM CONSTRAINT VARIABLES 
# The NLP approach requires us to solve equilibrium constraint variables
var EV {X};        	# Expected Value Function of each state

# END OF DEFINING STRUCTURAL PARAMETERS AND ENDOGENOUS VARIABLES #


#  DECLARE AUXILIARY VARIABLES  #
#  Define auxiliary variables to economize on expressions	

#  Create Cost variable to represent the cost function; 
var travelCost {(t, j) in X, k in D} = valueOfTime*travelTime[j, k]*T/60;

var choiceUtil {(t,j) in X, k in D} = 
    if j == k then
        actvUtil[t,j] + beta*EV[(t+1) mod H, j]
    else
        - travelCost[t,j,k] + beta*EV[(t+travelTime[j,k]+1) mod H, k];

var choiceProb {(t,j) in X, k in D} = exp( choiceUtil[t,j,k] - choiceUtil[t,j,1] )
									/ exp( EV[t,j] - choiceUtil[t,j,1] );

#  END OF DECLARING AUXILIARY VARIABLES #

# DEFINE OBJECTIVE FUNCTION AND CONSTRAINTS #

# Define the objective: Likelihood function 
#   The likelihood function contains two parts
#   First is the likelihood that the engine is replaced given time t state in the data.
#   Second is the likelihood that the observed transition between t-1 and t would have occurred.
maximize likelihood0: 0;

#  Define the constraints

subject to
	Bellman_Eqn {(t,j) in X}:
	    EV[t,j] = log( sum {k in D} exp( choiceUtil[t,j,k] - choiceUtil[t,j,1] ) )
				+ choiceUtil[t,j,1];

#  Put bound on EV; this should not bind, but is a cautionary step to help keep algorithm within bounds
    EVBound {(t,j) in X}: EV[t,j] <= 10000;

# END OF DEFINING OBJECTIVE FUNCTION AND CONSTRAINTS

# Name the problem
problem MarkovActvDP:

# Choose the objective function
likelihood0,

# List the variables
EV, valueOfTime, choiceProb, choiceUtil, actvUtil, b, c, Um,

# List the constraints
Bellman_Eqn,
EVBound;

# END OF DEFINING THE MLE OPTIMIZATION PROBLEM
