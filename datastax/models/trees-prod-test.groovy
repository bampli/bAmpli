// --------------------------------------------------------------------------
// 1: Get a list of sensors that connected with Georgetown in a time window
// wrap our query of valid paths in a method called getSensorsFromTower
def getSensorsFromTower(g, start, tower){
    sensors = g.withSack(start).V(tower).as("startingTower").
                        repeat(inE("send").as("sendEdge").
                               where(eq("sendEdge")).
                                   by(sack()).
                                   by("timestep").
                               sack(minus).
                               by(constant(1)).
                               outV().as("visitedVertex").
                               simplePath()).
                        times(start+1).
                        as("endingSensor").
                        select("endingSensor").
                        by(values("sensor_name")).
                        toList()
    return sensors;
}
// get Georgetown tower vertex              
tower = g.V().has("Tower", "tower_name", "Georgetown").next();

// create a list of sensors
atRiskSensors = [];  

// loop through a window of time
for(time = 0; time < 6; time++){  
    // use getSensorsFromTower to add all sensors into Georgetown's list at this time
    atRiskSensors.add(getSensorsFromTower(g, time, tower));
}

// flatten the list to only the unique sensor ids
atRiskSensors = atRiskSensors.flatten().unique();

// --------------------------------------------------------------------------
// 2: For each at risk sensor, find all towers they communicated with
// wrap our query of valid paths in a method called getSensorsFromTower
def getTowersFromSensor(g, start, sensor) {
    towers = g.withSack(start).V(sensor).as("startingSensor").
                until(hasLabel("Tower")).
                repeat(outE("send").as("sendEdge").
                       where(eq("sendEdge")).
                         by(sack()).
                         by("timestep").
                       inV().
                       as("visitedVertex").
                       sack(sum).
                       by(constant(1))).
                as("endingTower").
                select("endingTower").
                by(values("tower_name")).
                dedup().
                toList()
    return towers;
}

otherTowers = [:];                         // create a map

for(i=0; i < atRiskSensors.size(); i++){  // loop through all sensors
    otherTowers[atRiskSensors[i]] = [];    // initialize the map for a sensor
    sensor = g.V().has("Sensor", "sensor_name", atRiskSensors[i]).next();
    for(time = 0; time < 6; time++){      // loop through a window of time
        // use getTowersFromSensor to add all towers into the map for this sensor at this time
        otherTowers[atRiskSensors[i]].add(getTowersFromSensor(g, time, sensor));
    }
    // flatten the list to only the unique tower names
    otherTowers[atRiskSensors[i]] = otherTowers[atRiskSensors[i]].flatten().
                                                                  unique();
}
otherTowers 
