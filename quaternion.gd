class Quaternion:
	var v
	var s
	
	func _init(axis=Vector3(1.0,0.0,0.0),theta=0.0):
		if axis.length() > 0.0:
			axis = axis.normalized()
		self.v = sin(0.5*theta)*axis
		self.s = cos(0.5*theta)
		#print("[",s,",",v,"]")
	
	func normalized():
		var l = s*s + v.x*v.x+ v.y*v.y + v.z*v.z
		l = sqrt(l)
		v = v/l
		s = s/l
		
	
	func evolve( w, dT):
		var axis = w.normalized()
		
		var tempQ = load("res://quaternion.gd").Quaternion.new(Vector3(1,0,0),0) 
		tempQ.v = sin(0.5 * w.length() * dT) * axis
		tempQ.s = cos(0.5 * w.length() * dT)
		
		return tempQ.mul(self)
	
	
	func ptr():
		print("[",s,",",v,"]")
	
	func _str():
		return "[ " +str(v) + "," + str(s) + " ]"
	
	func get_axis():
		return self.v.normalized()
		
	func get_angle():
		return 2*acos(s)
	
	func conjugate():
		return(load("res://quaternion.gd").Quaternion.new(-self.get_axis(),get_angle()))
		

		
	func mul(Q2 = Quaternion()):
	
		var QResult = load("res://quaternion.gd").Quaternion.new(Vector3(1,0,0),0) 
		QResult.s = s*Q2.s - v.dot(Q2.v)
		QResult.v = s*Q2.v + Q2.s*v + v.cross(Q2.v)
		QResult.normalized()
	
		return QResult