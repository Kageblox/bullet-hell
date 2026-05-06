class_name HarmonicMotionParamsResource
extends Resource
## Resource file used for Harmonic Motion
##
## Cached set of motion parameters that can be used to efficiently update [br]
## multiple springs using the same time step, angular frequency and damping [br]
## ratio. [br]

@export var m_posPosCoef: float = 0
@export var m_posVelCoef: float = 0
@export var m_velPosCoef: float = 0
@export var m_velVelCoef: float = 0

func _init(
	_m_posPosCoef: float = 0,
	_m_posVelCoef: float = 0,
	_m_velPosCoef: float = 0,
	_m_velVelCoef: float = 0
) -> void:
	m_posPosCoef = _m_posPosCoef
	m_posVelCoef = _m_posVelCoef
	m_velPosCoef = _m_velPosCoef
	m_velVelCoef = _m_velVelCoef
	
