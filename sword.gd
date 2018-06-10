extends MeshInstance

onready var Angular_velocity = Vector3( 0,0, 0)
onready var Velocity         = Vector3(10,0, 0)
var Principal_Moments_of_Inertia = Vector3(10.0,1.0,10.0)

var R    = 7.5
var I    = 0
var mass = 2

var angle = 0
var deltaAngle = 0
var block = false

var normal = Vector3(0,R,0)

var modificator = Vector3(0,0,0)

var Fa   =  Vector3(5,5,5) 
const f    =  0.33

const g   = 9.81


var Fm   = Vector3(0,0,0)
var Fm_1 = Vector3(0,0,0)
var Fr   = Vector3(0.0,200.0,100.0)
var Fg   = Vector3(0,mass*g,0)

var Q1 = load("res://quaternion.gd").Quaternion.new(Vector3(1,0,0),0) 
var Q2 = load("res://quaternion.gd").Quaternion.new(Vector3(1.0,2.0,3.0),4.0)


var QR   = load("res://quaternion.gd").Quaternion.new(Vector3(1,0,0),2)
var QR_1 = QR.conjugate()

var origin = get_transform().origin
var transformationO = get_transform()
var transformationE = get_transform()

var de = 0.1

var a = Vector3(0,0,0)

var bas

func _input(event):

	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_SPACE:
			get_parent().get_parent().get_node("Env").get_node("floor").translation = bas
			Fr   = Vector3(0,200,100)
			
		if event.pressed and event.scancode == KEY_Z:
			Fr   -= Vector3(0,10,10)
			
		if event.pressed and event.scancode == KEY_X:
			Fr   += Vector3(0,10,10)
			
		if event.pressed and event.scancode == KEY_Q:
			modificator += Vector3(2,2,2)
			
		
		if event.pressed and event.scancode == KEY_R:
			modificator = Vector3(0,0,0)
	pass


func _ready():
	bas = get_parent().get_parent().get_node("Env").get_node("floor").translation
	pass

func evloveAngularVelocity(dT):
	
	Angular_velocity = 10 * Vector3(deltaAngle,deltaAngle,deltaAngle) + modificator
	deltaAngle = Velocity.length()*dT*10
	
	if Velocity.length() == 0:
		deltaAngle = 0

	
func evolveTransfomation():
	var QVe2 = load("res://quaternion.gd").Quaternion.new(Vector3(0,0,0),0)
		
	QVe2.v = transformationO.basis[0]
	QVe2.s = 0
	QVe2.normalized()
	QVe2 = QR.mul(QVe2).mul(QR_1)
		
	transformationE.basis[0] = QVe2.get_axis()
	
	QVe2.v = transformationO.basis[1]
	QVe2.s = 0
	QVe2.normalized()
	QVe2 = QR.mul(QVe2).mul(QR_1)
		
	transformationE.basis[1] = QVe2.get_axis()
	normal = QVe2.get_axis()
	
	QVe2.v = transformationO.basis[2]
	QVe2.s = 0
	QVe2.normalized()
	QVe2 = QR.mul(QVe2).mul(QR_1)
		
	transformationE.basis[2] = QVe2.get_axis()

func bounce():	
	Fr.y = -f*Fr.y
	if abs(Fr.y) < 8:
		block = true
		Fr.y = 0

func collisionCheck():
	if( !get_parent().get_parent().get_node("Env").get_node("floor").translation.y  < (get_parent().translation.y - R)):
		get_parent().translation.y = get_parent().get_parent().get_node("Env").get_node("floor").translation.y +R
		bounce()

func quaterionsEvolve( dT ):
	QR   = QR.evolve(Angular_velocity,dT)
	QR_1 = QR.conjugate()

func MangusF(delta):
	
	if block:
		Fm   = Vector3(0,0,0)
		Fm_1 = Vector3(0,0,0)
	else:
		Fm_1 = Fm
		Fm   = 2*Velocity.cross(Angular_velocity)


func Vmove(delta):

	if Fr.length() == 0 :
		return

	if( block ):
		
		if abs(Fr.z) < 0.1 :
			Fr.z = 0
		else:
			if Fr.z > 0:
				Fr -= Vector3(0,0,f*mass*abs(a.z)*delta)
			else :
				Fr += Vector3(0,0,f*mass*abs(a.z)*delta)

		if abs(Fr.x) < 0.1 :
			Fr.x = 0

		else:
			if Fr.x > 0:
				Fr -= Vector3(f*mass*abs(a.x)*delta,0,0)
			else :
				Fr += Vector3(f*mass*abs(a.x)*delta,0,0)

	if !(block and Fr.y == 0) :
		Fr -= Fg*delta

	Fr += ( Fm - Fm_1 )
			
	a = Fr/mass
	Velocity = a * delta

	get_parent().move(Velocity)

func _physics_process(delta):
	#Angular_velocity += delta*torque(delta)/Principal_Moments_of_Inertia # w opytmalnym układzie współrzędnych omega || I*omega!
	de = delta
	MangusF(delta)

	collisionCheck()
	Vmove(delta)

	evloveAngularVelocity(delta)
	quaterionsEvolve(delta)
	evolveTransfomation()

	set_transform(transformationE)
	
	#self.rotate(Angular_velocity.normalized(),Angular_velocity.length()*delta)
	# TODO: Zakomentować powyższą linię i sformułować obroty korzystając z klasy Quternion (z pliku quaternion.gd).
	#angle += 1
	
# Moment siły
func torque(delta):
	return Vector3(0.0,0.0,0.1)-0.1*Angular_velocity