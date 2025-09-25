extends Timer


func bpmStart(bpm:float):
	
	## translate bpm to bps
	var bps = (60.00/bpm) 
	
	wait_time = bps
	start()
