# Title: A Dynamic Markov Activity-Travel Scheduler
# Author: Xiong Yiliang <wlxiong@gmail.com> 2013

# Go to the NEOS Server (google "NEOS Server for Optimization").
# Click on "NEOS Solvers" and then go to "Nonlinearly Constrained Optimization"
# You can use any of the constrained optimization solvers that take AMPL input. 

# AMPL Model File:   MarkovActv.mod
# AMPL Data File:    MarkovActv.dat
# AMPL Command File: MDPNonlinearEqn.run, JointMDPNonlinearEqn.run
#                    MDPStateAction.run, JointMDPStateAction.run
#                    MLEMathProgEC.run, JointMLEMathProgEC.run

# control of debug logging
param debug_log;

# SET UP THE MODEL and DATA #

#  Define and process the data
param T;        # the equivalent minutes of a time episode
param H;        # number of time episode in the data
param DH;       # the longest duration for a decision
set TIME := 0..(H-1);   # TIME is the vector of time episodes
param N := 2;           # number of individuals in the household
set PERS := 1..N;       # PERS is the index set of individuals
param M;                # number of activities, including HOME
set ACTV := 1..M;       # ACTV is the index set of activities
param HOME;             # define HOME activity
set WORK {n in PERS};   # define the work activity for each household member

# generated time serise data
param n1;				# a specific household member
param I;				# sample size
set SAMPLE := 1..I;       # sample IDs
param xt {SAMPLE, TIME};  # state: current activity
param dx {SAMPLE, TIME};  # decision: activity type
param dh {SAMPLE, TIME};  # decision: activity duration
param xt1 {SAMPLE, TIME}; # state: current activity of person 1
param xt2 {SAMPLE, TIME}; # state: current activity of person 2
param dx1 {SAMPLE, TIME}; # decision: activity type of person 1
param dx2 {SAMPLE, TIME}; # decision: activity type of person 2

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
param isFeasibleCoState {t in 0..H, (j1,j2) in AW1xAW2} default 0;
# Declare the feasible choices
param isFeasibleChoice {n in PERS, t in 0..H, j in AUW[n], k in AUW[n], h in 1..DH} default 0;

# Define the state space used in the dynamic programming part
# X is the index set of states
set X {n in PERS}:= {t in TIME, j in AUW[n]: isFeasibleState[n,t,j] == 1};
# XX is the set of composite states
set XX := {t in TIME, (j1,j2) in AW1xAW2: 
	isFeasibleState[1,t,j1] == 1 and 
	isFeasibleState[2,t,j2] == 1 and 
	isFeasibleCoState[t,j1,j2] == 1};
# DTRAVEL is the index set of travel decisions
set DT {n in PERS, (t,j) in X[n]} := {k in AUW[n], h in 1..DH: 
	k != j and h == travelTime[t,j,k] and isFeasibleChoice[n,t,j,k,h] == 1};
# DA is the index set of activity decisions
set DA {n in PERS, (t,j) in X[n]} := {k in AUW[n], h in 1..DH: 
	k == j and isFeasibleChoice[n,t,j,k,h] == 1};
# D is the union of sets of travel and activity decisions
set D {n in PERS, (t,j) in X[n]} := DT[n,t,j] union DA[n,t,j];
# DD is the set of composite decisions. To simplify the state transition, 
# the activity durations of the component decisions should be the same.
set DD {(t,j1,j2) in XX} := {a1 in AUW[1], a2 in AUW[2], h in 1..DH: 
	(a1,h) in D[1,t,j1] and (a2,h) in D[2,t,j2]};

# Parameters and definition of transition process

# Define discount factor. We fix beta since it can't be identified.
param beta;      	 # discount factor

# END OF MODEL and DATA SETUP #


# DEFINING STRUCTURAL PARAMETERS and ENDOGENOUS VARIABLES TO BE SOLVED #

# value of time
param VoT >= 0;

# theta: parameter of the logit choice model
param theta >= 0;

# intra-household interaction coeffcient for each activity
var rho {ALLACTV} >= -1.0, <= 1.0;
# true value
param rho0 {ALLACTV} >= -1.0, <= 1.0;
# estimated value
param rho_ {ALLACTV} >= -1.0, <= 1.0;

# PARAMETERS OF CAUCHY DISTRIBUTION
# Is Cauchy distribution used ? 
var IS_CAUCHY;
# Activity parameters
var Um {PERS cross ALLACTV} >= 0, <= 5000;
var b  {PERS cross ALLACTV} >= 0, <= 1440;
var c  {PERS cross ALLACTV} >= 0, <= 600;
# True parameters
param Um0 {PERS cross ALLACTV} >= 0, <= 5000;
param b0  {PERS cross ALLACTV} >= 0, <= 1440;
param c0  {PERS cross ALLACTV} >= 0, <= 600;
# Estimated parameters
param Um_ {PERS cross ALLACTV} >= 0, <= 5000;
param b_  {PERS cross ALLACTV} >= 0, <= 1440;
param c_  {PERS cross ALLACTV} >= 0, <= 600;


# PARAMETERS OF BELL-SHAPED FUNCTION
# Activity parameters
param U0 {PERS cross ALLACTV};
param U1 {PERS cross ALLACTV};
param xi {PERS cross ALLACTV} >= 0, <= 1440;
param gamma {PERS cross ALLACTV};
param lambda {PERS cross ALLACTV};

# Marginal activity utility
param PI := 3.141592653;
var actvUtil {n in PERS, j in AUW[n], t in 0..H} = 
	if IS_CAUCHY == 1 then
		# Scaled Cauchy distribution
		if j == HOME and t >= H/2 then
			Um[n,j]/PI*( atan( ( t*T+T-(b[n,j]+1440) )/c[n,j] ) - atan( ( t*T-(b[n,j]+1440) )/c[n,j]) )
		else
			Um[n,j]/PI*( atan( ( t*T+T-b[n,j])/c[n,j] ) - atan( ( t*T-b[n,j])/c[n,j]) )
	else
		# Bell-shaped marginal utility function
		if j == HOME and t >= H/2 then
			T * ( U0[n,j] + 
				  gamma[n,j]*lambda[n,j]*U1[n,j] / 
					 ( exp( gamma[n,j] * (1440.0 - t*T - xi[n,j]) ) *
					   ( 1 + exp( -gamma[n,j]*(1440.0 - t*T - xi[n,j]) ) )**(lambda[n,j]+1) ) )
		else
			T * ( U0[n,j] + 
				  gamma[n,j]*lambda[n,j]*U1[n,j] / 
					 ( exp( gamma[n,j] * (t*T - xi[n,j]) ) *
					   ( 1 + exp( -gamma[n,j]*(t*T - xi[n,j]) ) )**(lambda[n,j]+1) ) );


# DECLARE EQUILIBRIUM CONSTRAINT VARIABLES 
# The NLP approach requires us to solve equilibrium constraint variables

# Define initial values for EV
param initEV;

# Declare expected value of each component state
var EV {n in PERS, t in 0..H, j in AUW[n]} default initEV;

# Declare expected value of each composite state
var EW {t in 0..H, (j1,j2) in AW1xAW2} default initEV;
# Declare lower bound of EW
var lower {t in 0..H, (j1,j2) in AW1xAW2};
# Declare upper bound of EW
var upper {t in 0..H, (j1,j2) in AW1xAW2};

# END OF DEFINING STRUCTURAL PARAMETERS AND ENDOGENOUS VARIABLES #


#  DECLARE AUXILIARY VARIABLES  #
#  Define auxiliary variables to economize on expressions	

#  Define the total discounted utility of pursuing activity j in time (t, t+h-1)
var sumActvUtil {n in PERS, (t,j) in X[n], (k,h) in DA[n,t,j]} = 
	sum {s in 1..h} beta**(s-1) * actvUtil[n,k,t+s];
#  Define the total discounted utility of traveling from j to k departing at t
param sumTravelCost {n in PERS, (t,j) in X[n], (k,h) in DT[n,t,j]} = 
	sum {s in 1..h} beta**(s-1) * T*VoT/60;
# Define the joint utility
var jointActvUtil {(t,j1,j2) in XX, (a1, a2, h) in DD[t,j1,j2]} = 
	if a1 == a2 then
		sum {s in 1..h} beta**(s-1) * sqrt(actvUtil[1,a1,t+s]*actvUtil[2,a2,t+s])
	else
		0.0;

# Define the utility of selecting decision (k,h)
var choiceUtil {n in PERS, (t,j) in X[n], (k,h) in D[n,t,j]} = 
    if k == j then
          sumActvUtil[n,t,j,k,h]
    else
        - sumTravelCost[n,t,j,k,h];

# Declare the choice probability
var choiceProb {n in PERS, (t,j) in X[n], (k,h) in D[n,t,j]} = 
	exp( theta * (choiceUtil[n,t,j,k,h] + 
				  beta**h * EV[n,(t+h),k]) - 
		 theta * EV[n,t,j] );

# Define the joint decision utility
var jointChoiceUtil {(t,j1,j2) in XX, (a1, a2, h) in DD[t,j1,j2]} =
	if a1 == j1 and a2 == j2 and a1 == a2 then
		sumActvUtil[1,t,j1,a1,h] + sumActvUtil[2,t,j2,a2,h] + 
		rho[a1] * jointActvUtil[t,j1,j2,a1,a2,h]
	else if a1 == j1 and a2 == j2 then
		sumActvUtil[1,t,j1,a1,h] + sumActvUtil[2,t,j2,a2,h]
	else if a1 == j1 then
		sumActvUtil[1,t,j1,a1,h] - sumTravelCost[2,t,j2,a2,h]
	else if a2 == j2 then
		- sumTravelCost[1,t,j1,a1,h] + sumActvUtil[2,t,j2,a2,h]
	else
		- sumTravelCost[1,t,j1,a1,h] - sumTravelCost[2,t,j2,a2,h];

# Declare the joint choice probability
var jointChoiceProb {(t,j1,j2) in XX, (a1, a2, h) in DD[t,j1,j2]} =
	exp( theta * (jointChoiceUtil[t,j1,j2,a1,a2,h] + 
				  beta**h * EW[t,a1,a2]) - 
		 theta * EW[t,j1,j2] );


#  END OF DECLARING AUXILIARY VARIABLES #

# DEFINE OBJECTIVE FUNCTION AND CONSTRAINTS #

# Define the objective: Likelihood function 
#   The likelihood function contains two parts
#   First is the likelihood that the engine is replaced given time t state in the data.
#   Second is the likelihood that the observed transition between t-1 and t would have occurred.
maximize likelihood0: 0;

maximize likelihood:
	sum {i in SAMPLE, t in TIME}
		if (t, xt1[i,t]) in X[n1] and (dx1[i,t], dh[i,t]) in D[n1, t, xt1[i,t]] then
			log( choiceProb[ n1, t, xt1[i,t], dx1[i,t], dh[i,t] ] )
		else
			0.0;

maximize likelihood_joint:
	sum {i in SAMPLE, t in TIME}
		if (t, xt1[i,t], xt2[i,t]) in XX and (dx1[i,t], dx2[i,t], dh[i,t]) in DD[ t, xt1[i,t], xt2[i,t] ] then
			log( jointChoiceProb[ t, xt1[i,t], xt2[i,t], dx1[i,t], dx2[i,t], dh[i,t] ] )
		else
			0.0;


#  Define the Bellman equation of the component MDP model
subject to Bellman_Eqn {n in PERS, (t,j) in X[n]}:
	EV[n,t,j] = if card(D[n,t,j]) > 1 then
					log( sum {(k,h) in D[n,t,j]}
							exp( theta * (choiceUtil[n,t,j,k,h] + 
										  beta**h * EV[n,(t+h),k]) ) ) / theta
				else	 sum {(k,h) in D[n,t,j]}
							(choiceUtil[n,t,j,k,h] + beta**h * EV[n,(t+h),k]);
subject to Bellman_EqnH {n in PERS}: 
	EV[n,H,HOME] = EV[n,0,HOME];


# Define the Bellman equation of the composite MDP model
subject to Bellman_Joint {(t,j1,j2) in XX}:
	EW[t,j1,j2] = if card(DD[t,j1,j2]) > 1 then
					log( sum {(a1,a2,h) in DD[t,j1,j2]}
							exp( theta * (jointChoiceUtil[t,j1,j2,a1,a2,h] + 
										  beta**h * EW[t,a1,a2]) ) ) / theta
				  else	 sum {(a1,a2,h) in DD[t,j1,j2]}
							(jointChoiceUtil[t,j1,j2,a1,a2,h] + beta**h * EW[t,a1,a2]);
subject to Bellman_JointH: 
	EW[H,HOME,HOME] = EW[0,HOME,HOME];

# Define the Bellman equation for updating the lower and upper bounds
subject to Bellman_Lower {(t,j1,j2) in XX}:
	lower[t,j1,j2] = log( sum {(a1,a2,h) in DD[t,j1,j2]} 
								exp( theta * (jointChoiceUtil[t,j1,j2,a1,a2,h] + 
											  beta**h * lower[t,a1,a2]) ) ) / theta;
subject to Bellman_LowerH: 
	lower[H,HOME,HOME] = lower[0,HOME,HOME];
subject to Bellman_Upper {(t,j1,j2) in XX}:
	upper[t,j1,j2] = log( sum {(a1,a2,h) in DD[t,j1,j2]} 
								exp( theta * (jointChoiceUtil[t,j1,j2,a1,a2,h] + 
											  beta**h * upper[t,a1,a2]) ) ) / theta;
subject to Bellman_UpperH: 
	upper[H,HOME,HOME] = upper[0,HOME,HOME];

# Define the lower and upper bounds for EW
subject to LowerBound {(t,j1,j2) in XX}:
	EW[t,j1,j2] >= lower[t,j1,j2];
subject to UpperBound {(t,j1,j2) in XX}:
	EW[t,j1,j2] <= upper[t,j1,j2];

# Symmetric parameters
subject to Symmetric_Um {j in ACTV}: Um[1,j] = Um[2,j];
subject to Symmetric_b  {j in ACTV}:  b[1,j] =  b[2,j];
subject to Symmetric_c  {j in ACTV}:  c[1,j] =  c[2,j];

# END OF DEFINING OBJECTIVE FUNCTION AND CONSTRAINTS
