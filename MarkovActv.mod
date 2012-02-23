# Title: Constrained Optimization Approaches for Estimation of Structural Models
# Authors: Che-Lin Su and Kenneth L. Judd, November 2010
# Modified by Xiong Yiliang <wlxiong@gmail.com>

# Go to the NEOS Server (google "NEOS Server for Optimization").
# Click on "NEOS Solvers" and then go to "Nonlinearly Constrained Optimization"
# You can use any of the constrained optimization solvers that take AMPL input. 
# In the paper, we use the solver KNITRO.

# AMPL Model File:   MarkovActv.mod
# AMPL Data File:    MarkovActv.dat
# AMPL Command File: MarkovActv.run


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
# param travelTime {TIME cross ACTV cross ACTV};	# travel time over time
param travelTime {ACTV cross ACTV};

# Define the state space used in the dynamic programming part
set TIMEACTV := TIME cross ACTV;
/*set TIMEHOME := TIME cross {HOME};*/
set X := TIMEACTV;	# X is the index set of states
set D := ACTV;

# Parameters and definition of transition process

# Define discount factor. We fix beta since it can't be identified.
param beta;      	 # discount factor

# Data: (xt, dt)
param xt {PERS cross TIME};      # state of individual i
param dt {PERS cross TIME};      # activity choice of individual i

# END OF MODEL and DATA SETUP #

# DEFINING STRUCTURAL PARAMETERS and ENDOGENOUS VARIABLES TO BE SOLVED #
# value of time
var valueOfTime >= 0;

# true VoT
param trueValueOfTime >= 0;

# initial value of VoT
param initValueOfTime >= 0;

# transProb[i] defines transition probability that state in next time slice. 
# var transProb {1..M} >= 0;

# PARAMETERS OF CAUCHY DISTRIBUTION
# Activity Parameters
var Um {ACTV} >= 0;
var b {ACTV} >= 0, <= 1440;
var c {ACTV} >= 0;

# Define the ture parameters
param trueUm {ACTV};
param trueB {ACTV};
param trueC {ACTV};

# Define the initial values for parameters
param initUm {ACTV};
param initB {ACTV};
param initC {ACTV};

# PARAMETERS OF BELL-SHAPED FUNCTION
# Activity Parameters
var Uw {ACTV} >= 0;
var xi {ACTV} >= 0, <= 1440;
var gamma {ACTV} >= 0;
var lambda {ACTV} >= 0;

# Define the ture parameters
param trueUw {ACTV};
param trueXi {ACTV};
param trueGamma {ACTV};
param trueLambda {ACTV};

# Define the initial values for parameters
param initUw {ACTV};
param initXi {ACTV};
param initGamma {ACTV};
param initLambda {ACTV};

# Scaled Cauchy distribution
var actvUtil {(t,j) in X} = Um[j]/3.141592653*( atan( ( t*T+T-b[j])/c[j] ) - atan( ( t*T-b[j])/c[j]) );

# Bell-shaped profile
# var actvUtil {(t,j) in X} = gamma[j]*lambda[j]*Uw[j]/exp(gamma[j]*(t*T-xi[j]))/
#                             (1+exp(-gamma[j]*(t*T-xi[j])))^(lambda[j]+1)*T;

# DECLARE EQUILIBRIUM CONSTRAINT VARIABLES 
# The NLP approach requires us to solve equilibrium constraint variables
var EV {X};        	# Expected Value Function of each state

# Define initial values for EV
param initEV;

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

maximize likelihood: 
    sum {i in PERS, t in TIME} 
		if xt[i,t] <> -1 and dt[i,t] <> -1 then 
			log( choiceProb[ t, xt[i,t], dt[i,t] ] ) 
		else
			1.0;

#  Define the constraints

subject to
    Bellman_Eqn {(t,j) in X}:
        EV[t,j] = log( sum {k in D} exp( choiceUtil[t,j,k] - choiceUtil[t,j,1] ) )
				+ choiceUtil[t,j,1];

#  Put bound on EV; this should not bind, but is a cautionary step to help keep algorithm within bounds
    EVBound {(t,j) in X}: EV[t,j] <= 10000;

# END OF DEFINING OBJECTIVE FUNCTION AND CONSTRAINTS
