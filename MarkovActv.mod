# Title: MPEC Approach for Estimation of MDP Models
# Author: Xiong Yiliang <wlxiong@gmail.com> 2013

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
param N := 2;           # number of individuals in the household
set PERS := 1..N;       # PERS is the index set of individuals
param M;                # number of activities, including HOME
set ACTV := 1..M;       # ACTV is the index set of activities
param HOME;				# define HOME activity
set WORK {n in PERS};	# define the work activity for each household member

# shortcuts for set union and set product
set AUW {n in PERS} := ACTV union WORK[n];
set AW1xAW2 := AUW[1] cross AUW[2];
set ALLACTV := ACTV union WORK[1] union WORK[2];

# Travel time varies over time of the day
param travelTime {TIME cross AW1xAW2};

param opening {ALLACTV};	# activity opening time
param closing {ALLACTV};	# activity closing time

# Declare the feasible states
param isFeasibleState {n in PERS, t in 0..H, j in AUW[n]} default 0;
# Declare the feasible choices
param isFeasibleChoice {n in PERS, t in 0..H, j in AUW[n], k in AUW[n], h in TIME} default 0;

# Define the state space used in the dynamic programming part
# X is the index set of states
set X {n in PERS}:= {t in TIME, j in AUW[n]: isFeasibleState[n,t,j] == 1};
# XX is the set of composite states
set XX := {t in TIME, (j,k) in AW1xAW2: 
	isFeasibleState[1,t,j] == 1 and isFeasibleState[2,t,k] = 1};
# DTRAVEL is the index set of travel decisions
set DT {n in PERS, (t,j) in X[n]} := {k in AUW[n], h in TIME: 
	k != j and h == travelTime[t,j,k] and isFeasibleChoice[n,t,j,k,h] == 1};
# DA is the index set of activity decisions
set DA {n in PERS, (t,j) in X[n]} := {k in AUW[n], h in TIME: 
	k == j and isFeasibleChoice[n,t,j,k,h] == 1};
# D is the union of sets of travel and activity decisions
set D {n in PERS, (t,j) in X[n]} := DT[n,t,j] union DA[n,t,j];
# DD is the set of composite decisions
# to simplify the state transition, the activity durations of the component decisions should be the same
set DD {(t,j,k) in XX} := {(a1, h1) in D[1,t,j], (a2,h2) in D[2,t,k]: h1 == h2};

# Parameters and definition of transition process

# Define discount factor. We fix beta since it can't be identified.
param beta;      	 # discount factor

# Data: (xt, dt)
# param xt {PERS cross TIME};      # state of individual i
# param dt {PERS cross TIME};      # activity choice of individual i

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
var Um {ALLACTV} >= 0, <= 5000;
var b {ALLACTV} >= 0, <= 1440;
var c {ALLACTV} >= 0, <= 600;

# Define the ture parameters
param trueUm {ALLACTV};
param trueB {ALLACTV};
param trueC {ALLACTV};

# Define the initial values for parameters
param initUm {ALLACTV};
param initB {ALLACTV};
param initC {ALLACTV};

# Define the estimated values of paramaters
param Um_ {ALLACTV};
param b_ {ALLACTV};
param c_ {ALLACTV};

# PARAMETERS OF BELL-SHAPED FUNCTION
# Activity Parameters
var Uw {ALLACTV} >= 0;
var xi {ALLACTV} >= 0, <= 1440;
var gamma {ALLACTV} >= 0;
var lambda {ALLACTV} >= 0;

# Define the ture parameters
param trueUw {ALLACTV};
param trueXi {ALLACTV};
param trueGamma {ALLACTV};
param trueLambda {ALLACTV};

# Define the initial values for parameters
param initUw {ALLACTV};
param initXi {ALLACTV};
param initGamma {ALLACTV};
param initLambda {ALLACTV};

# Scaled Cauchy distribution
var actvUtil {n in PERS, t in 0..H, j in AUW[n]} = 
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
# expected value of each component state
var EV {n in PERS, t in 0..H, j in AUW[n]} default initEV;
# expected value of each composite state
var EW {t in 0..H, (j,k) in AW1xAW2};
# lower bound of EV
var lowerEV {t in 0..H, (j,k) in AW1xAW2};
# upper bound of EV
var upperEV {t in 0..H, (j,k) in AW1xAW2};

# END OF DEFINING STRUCTURAL PARAMETERS AND ENDOGENOUS VARIABLES #


#  DECLARE AUXILIARY VARIABLES  #
#  Define auxiliary variables to economize on expressions	

#  Define the total discounted utility of pursuing activity j in time (t, t+h-1)
var sumActvUtil {n in PERS, (t,j) in X[n], (k,h) in DA[n,t,j]} = 
	sum {s in 1..h} beta**(s-1) * actvUtil[n,t+s,k];
#  Define the total discounted utility of traveling from j to k departing at t
var sumTravelCost {n in PERS, (t,j) in X[n], (k,h) in DT[n,t,j]} = 
	sum {s in 1..h} beta**(s-1) * T*VoT/60;

# Define the utility of selecting decision (k,h)
var choiceUtil {n in PERS, (t,j) in X[n], (k,h) in D[n,t,j]} = 
    if k == j then
          sumActvUtil[n,t,j,k,h] + beta**h * EV[n,(t+h), k]
    else
        - sumTravelCost[n,t,j,k,h] + beta**h * EV[n,(t+h), k];

var choiceProb {n in PERS, (t,j) in X[n], (k,h) in D[n,t,j]} = 
	exp( theta*choiceUtil[n,t,j,k,h] ) / 
	exp( theta*EV[n,t,j] );

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

subject to Bellman_Eqn {n in PERS, (t,j) in X[n]}:
    EV[n,t,j] = log( sum {(k,h) in D[n,t,j]} exp( theta*choiceUtil[n,t,j,k,h] ) ) / theta;
subject to Bellman_EqnH {n in PERS}: EV[n,H,HOME] = EV[n,0,HOME];

# END OF DEFINING OBJECTIVE FUNCTION AND CONSTRAINTS
