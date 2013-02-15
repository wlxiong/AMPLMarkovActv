# Title: MPEC Approach for Estimation of MDP Models
# Author: Xiong Yiliang <wlxiong@gmail.com> 2012

# Go to the NEOS Server (google "NEOS Server for Optimization").
# Click on "NEOS Solvers" and then go to "Nonlinearly Constrained Optimization"
# You can use any of the constrained optimization solvers that take AMPL input. 

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
param M;                # number of activities, including HOME
set ACTV := 1..M;       # ACTV is the index set of activities
param HOME;				# define HOME activity

# Travel time varies over time of the day
param travelTime {TIME cross ACTV cross ACTV};

param opening {ACTV};	# activity opening time
param closing {ACTV};	# activity closing time

param isFeasibleState {0..H cross ACTV} default 0;	# Declare the feasible states
param isFeasibleChoice {0..H cross ACTV cross ACTV cross TIME} default 0;	# Declare the feasible choices

# Define the state space used in the dynamic programming part
# X is the index set of states
set X := {t in TIME, j in ACTV:	isFeasibleState[t,j] == 1};
# DTRAVEL is the index set of travel decisions
set DTRAV {(t,j) in X} := {k in ACTV, h in TIME: k != j and h == travelTime[t,j,k] and isFeasibleChoice[t,j,k,h] == 1};
# DACTV is the index set of activity decisions
set DACTV {(t,j) in X} := {k in ACTV, h in TIME: k == j and isFeasibleChoice[t,j,k,h] == 1};
# D is the union of sets of travel and activity decisions
set D {(t,j) in X} := DTRAV[t,j] union DACTV[t,j];

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
param initVoT;

# estimated VoT
param VoT_;

# theta: parameter of the logit choice model
var theta >= 0;

# true value of theta
param trueTheta >= 0;

# initial value of theta
param initTheta;

# transProb[i] defines transition probability that state in next time slice. 
# var transProb {1..M} >= 0;

# PARAMETERS OF CAUCHY DISTRIBUTION
# Activity Parameters
var Um {ACTV} >= 0, <= 5000;
var b {ACTV} >= 0, <= 1440;
var c {ACTV} >= 0, <= 600;

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
var actvUtil {(t,j) in 0..H cross ACTV} = 
	if j == HOME and t < H/2 then 
		Um[j]/3.141592653*( atan( ( t*T+T-b[j])/c[j] ) - atan( ( t*T-b[j])/c[j]) )
	else if j == HOME and t >= H/2 then
		Um[j]/3.141592653*( atan( ( t*T+T-(b[j]+1440) )/c[j] ) - atan( ( t*T-(b[j]+1440) )/c[j]) )
	else
		Um[j]/3.141592653*( atan( ( t*T+T-b[j])/c[j] ) - atan( ( t*T-b[j])/c[j]) );

# DECLARE EQUILIBRIUM CONSTRAINT VARIABLES 
# The NLP approach requires us to solve equilibrium constraint variables

# Define initial values for EV
param initEV;
# Expected Value Function of each state
var EV {0..H cross ACTV} default initEV;

# END OF DEFINING STRUCTURAL PARAMETERS AND ENDOGENOUS VARIABLES #


#  DECLARE AUXILIARY VARIABLES  #
#  Define auxiliary variables to economize on expressions	

#  Define the total discounted utility of pursuing activity j in time (t, t+h-1)
var sumActvUtil {(t,j) in X, (k,h) in DACTV[t,j]} = sum {s in 1..h} beta**(s-1) * actvUtil[t+s,k];
#  Define the total discounted utility of traveling from j to k departing at t
var sumTravelCost {(t,j) in X, (k,h) in DTRAV[t,j]} = sum {s in 1..h} beta**(s-1) * T*VoT/60;

# Define the utility of selecting decision (k,h)
var choiceUtil {(t,j) in X, (k,h) in D[t,j]} = 
    if k == j then
          sumActvUtil[t,j,k,h] + beta**h * EV[(t+h), k]
    else
        - sumTravelCost[t,j,k,h] + beta**h * EV[(t+h), k];

var choiceProb {(t,j) in X, (k,h) in D[t,j]} = 
	exp( theta*choiceUtil[t,j,k,h] ) / 
	exp( theta*EV[t,j] );

#  END OF DECLARING AUXILIARY VARIABLES #

# DEFINE OBJECTIVE FUNCTION AND CONSTRAINTS #

# TODO calculate profile of likelihood and draw 3D diagrams

# Define the objective: Likelihood function 
#   The likelihood function contains two parts
#   First is the likelihood that the engine is replaced given time t state in the data.
#   Second is the likelihood that the observed transition between t-1 and t would have occurred.
maximize likelihood0: 0;

# maximize likelihood: 
# 	sum {i in PERS, t in TIME} 
# 		if (t, xt[i,t]) in X and dt[i,t] in D[t, xt[i,t]] then
# 			log( choiceProb[ t, xt[i,t], dt[i,t] ] ) 
# 		else
# 			0.0;

#  Define the constraints

subject to Bellman_Eqn {(t,j) in X}:
    EV[t,j] = log( sum {(k,h) in D[t,j]} exp( theta*choiceUtil[t,j,k,h] ) ) / theta;
subject to Bellman_EqnH: EV[H,HOME] = EV[0,HOME];

# END OF DEFINING OBJECTIVE FUNCTION AND CONSTRAINTS
