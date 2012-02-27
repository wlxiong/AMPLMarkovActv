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
set ACTV := 1..M;       # ACTV is the index set of activities
param HOME_AM;			# define the before work activity as HOME AM
param HOME_PM;			# define the after work activity as HOME PM

# TODO intra-household interaction
# TODO stochstic travel time
# TODO congested transport network
# TODO consider activity participation history
# set AA := 1 .. 2**M;	# index of power set of ACTV
# set HIST {k in AA} := {i in ACTV: ((k-1) div 2**(i-1)) mod 2 = 1};

# Travel time
# param travelTime {TIME cross ACTV cross ACTV};	# travel time over time
param travelTime {ACTV cross ACTV};

param isFeasibleState {0..H cross ACTV} default 0;	# Declare the feasible states
param isFeasibleChoice {0..H cross ACTV cross ACTV} default 0;	# Declare the feasible choices

# Define the state space used in the dynamic programming part
# X is the index set of states
set X := {t in TIME, j in ACTV:	isFeasibleState[t,j] == 1};
# D is the index set of choices
set D {(t,j) in X} := {k in ACTV: isFeasibleChoice[t,j,k] == 1};

# Parameters and definition of transition process

# Define discount factor. We fix beta since it can't be identified.
param beta;      	 # discount factor

# Data: (xt, dt)
param xt {PERS cross TIME};      # state of individual i
param dt {PERS cross TIME};      # activity choice of individual i

# END OF MODEL and DATA SETUP #

# DEFINING STRUCTURAL PARAMETERS and ENDOGENOUS VARIABLES TO BE SOLVED #
# value of time
var VoT >= 0;

# true VoT
param trueVoT >= 0;

# initial value of VoT
param initVoT >= 0;

# estimated VoT
param VoT_;

# theta: parameter of the logit choice model
var theta >= 0;

# true value of theta
param trueTheta >= 0;

# initial value of theta
param initTheta >= 0;

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

# Define the estimated values of paramaters
param Um_ {ACTV};
param b_ {ACTV};
param c_ {ACTV};

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

# Define initial values for EV
param initEV;
# Expected Value Function of each state
var EV {0..H cross ACTV} default initEV;

# END OF DEFINING STRUCTURAL PARAMETERS AND ENDOGENOUS VARIABLES #


#  DECLARE AUXILIARY VARIABLES  #
#  Define auxiliary variables to economize on expressions	

#  Create Cost variable to represent the cost function; 
var travelCost {(t, j) in X, k in D[t,j]} = VoT*travelTime[j, k]*T/60;

var choiceUtil {(t,j) in X, k in D[t,j]} = 
    if j == k then
        actvUtil[t,j] + beta*EV[(t+1), j]
    else
        - travelCost[t,j,k] + beta*EV[(t+travelTime[j,k]+1), k];

var choiceProb {(t,j) in X, k in D[t,j]} = 
	exp( theta*choiceUtil[t,j,k] ) / 
	exp( theta*EV[t,j] );

#  END OF DECLARING AUXILIARY VARIABLES #

# DEFINE OBJECTIVE FUNCTION AND CONSTRAINTS #

# TODO calculate profile of likelihood and draw 3D diagrams

# Define the objective: Likelihood function 
#   The likelihood function contains two parts
#   First is the likelihood that the engine is replaced given time t state in the data.
#   Second is the likelihood that the observed transition between t-1 and t would have occurred.
maximize likelihood0: 0;

maximize likelihood: 
	sum {i in PERS, t in TIME} 
		if (t, xt[i,t]) in X and dt[i,t] in D[t, xt[i,t]] then
			log( choiceProb[ t, xt[i,t], dt[i,t] ] ) 
		else
			1.0;

#  Define the constraints

subject to
    Bellman_Eqn {(t,j) in X}:
        EV[t,j] = log( sum {k in D[t,j]} exp( theta*choiceUtil[t,j,k] ) ) / theta;
	Bellman_EqnH:
		EV[H,HOME_PM] = 0.0;

#  Put bound on EV; this should not bind, but is a cautionary step to help keep algorithm within bounds
    EVBound {(t,j) in X}: EV[t,j] <= 10000;

# END OF DEFINING OBJECTIVE FUNCTION AND CONSTRAINTS
