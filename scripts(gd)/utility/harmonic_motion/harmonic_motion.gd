class_name HarmonicMotionUtility
## Utility Script for Harmonic Motion
##
## Referenced from: https://www.ryanjuckett.com/damped-springs/

## This function will compute the parameters needed to simulate a damped spring[br]
## over a given period of time.[br]
## - An angular frequency is given to control how fast the spring oscillates.[br]
## - A damping ratio is given to control how fast the motion decays.[br]
## damping ratio > 1: over damped[br]
## damping ratio = 1: critically damped[br]
## damping ratio < 1: under damped[br]
static func CalcDampedSpringMotionParams(
		deltaTime: float, # time step to advance
		angularFrequency: float, # angular frequency of motion
		dampingRatio: float # damping ratio of motion
		) -> HarmonicMotionParamsResource:
	const epsilon = 0.0001
	
	var pOutParams = HarmonicMotionParamsResource.new()
	
	# force values into legal range
	if dampingRatio< 0.0: dampingRatio = 0.0
	if angularFrequency < 0.0: angularFrequency = 0.0
	
	# if there is no angular frequency, the spring will not move and we can
	# return identity
	if angularFrequency < epsilon:
		pOutParams.m_posPosCoef = 1.0
		pOutParams.m_posVelCoef = 0.0
		pOutParams.m_velPosCoef = 0.0
		pOutParams.m_velVelCoef = 1.0
		return
	
	if dampingRatio > 1.0 + epsilon:
		# Over-Damped
		var za = -angularFrequency * dampingRatio
		var zb = angularFrequency * sqrt(dampingRatio * dampingRatio - 1.0)
		var z1 = za - zb
		var z2 = za + zb
		
		var e1 = exp(z1 * deltaTime)
		var e2 = exp(z2 * deltaTime)
		
		var invTwoZb = 1.0 / (2.0 * zb)
		
		var e1_Over_TwoZb = e1 * invTwoZb
		var e2_Over_TwoZb = e2 * invTwoZb
		
		var z1e1_Over_TwoZb = z1 * e1_Over_TwoZb
		var z2e2_Over_TwoZb = z2 * e2_Over_TwoZb
		
		pOutParams.m_posPosCoef = e1_Over_TwoZb * z2 - z2e2_Over_TwoZb + e2
		pOutParams.m_posVelCoef = -e1_Over_TwoZb + e2_Over_TwoZb
		
		pOutParams.m_velPosCoef = (z1e1_Over_TwoZb - z2e2_Over_TwoZb + e2) * z2
		pOutParams.m_velVelCoef = -z1e1_Over_TwoZb + z2e2_Over_TwoZb
	elif dampingRatio < 1.0 - epsilon:
		# Under-Damped
		var omegaZeta = angularFrequency * dampingRatio
		var alpha = angularFrequency * sqrt(1.0 - dampingRatio * dampingRatio)

		var expTerm = exp(-omegaZeta * deltaTime)
		var cosTerm = cos(alpha * deltaTime)
		var sinTerm = sin(alpha * deltaTime)
			
		var invAlpha = 1.0 / alpha

		var expSin = expTerm * sinTerm
		var expCos = expTerm * cosTerm
		var expOmegaZetaSin_Over_Alpha = expTerm * omegaZeta * sinTerm * invAlpha

		pOutParams.m_posPosCoef = expCos + expOmegaZetaSin_Over_Alpha
		pOutParams.m_posVelCoef = expSin * invAlpha

		pOutParams.m_velPosCoef = -expSin * alpha - omegaZeta * expOmegaZetaSin_Over_Alpha;
		pOutParams.m_velVelCoef = expCos - expOmegaZetaSin_Over_Alpha;
	else:
		# Critically Damped
		var expTerm = exp(-angularFrequency * deltaTime)
		var timeExp = deltaTime * expTerm
		var timeExpFreq = timeExp * angularFrequency

		pOutParams.m_posPosCoef = timeExpFreq + expTerm
		pOutParams.m_posVelCoef = timeExp

		pOutParams.m_velPosCoef = -angularFrequency * timeExpFreq
		pOutParams.m_velVelCoef = -timeExpFreq + expTerm
	
	return pOutParams

## This function will update the supplied position and velocity values over[br]
## according to the motion parameters.[br]
static func UpdateDampedSpringMotion(
	pPos: float, # position value to update
	pVel: float, # velocity value to update
	equilibriumPos: float, # position to approach
	params: HarmonicMotionParamsResource, # motion parameters to use
) -> Vector2:
	var oldPos = pPos - equilibriumPos # update in equilibrium relative space
	var oldVel = pVel
	
	pPos = oldPos * params.m_posPosCoef + oldVel * params.m_posVelCoef + equilibriumPos
	pVel = oldPos * params.m_velPosCoef + oldVel * params.m_velVelCoef
	
	return Vector2(pPos, pVel)
