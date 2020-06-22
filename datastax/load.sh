#!/bin/bash

export MSYS_NO_PATHCONV=1
export DSBULK="docker run -it josemottalopes/dsbulk:1.5.0 load -h 172.22.0.3 -k trees_dev"

############################################
# load the vertices
############################################
echo "Loading vertices into the graph $DEST_KS"

$DSBULK -t Sensor -url Sensor.csv -header true
$DSBULK -t Tower -url Tower.csv -header true


echo "Completed loading vertices into the graph $DEST_KS."

############################################
# load the edges
############################################
echo "Loading edges into the graph $DEST_KS"

$DSBULK -t send Sensor__send__Sensor -url Sensor__send__Sensor.csv -header true
$DSBULK -t send Sensor__send__Tower -url Sensor__send__Tower.csv -header true

echo "Completed loading edges into the graph $DEST_KS."

# #!/bin/bash

# # You may set the following variables inside script, or override corresponding
# # variables when running the script
# DEFAULT_DSBULK_PATH="docker run -it josemottalopes/dsbulk:1.5.0 load -h 172.22.0.3"
# DEFAULT_DEST_KS=trees_dev

# # Allow to override these variables via environment variables set before executing script
# DSBULK_PATH=${DSBULK_PATH:-$DEFAULT_DSBULK_PATH}
# DEST_KS=${DEST_KS:-$DEFAULT_DEST_KS}

# ############################################
# # Automated data loading 
# # Assuming you set DSBULK_PATH and DEST_KS
# ############################################

# # # collect directory variables
# # OLDWD="`pwd`"
# # SCRIPTDIR="`dirname $0`"
# # cd "$SCRIPTDIR"

# # # determine which dsbulk to use, in the case you already have it installed
# # # the path that is set in the script, takes over the value from PATH
# # DSBULK=$DSBULK_PATH/bin/dsbulk
# # if [ ! -f "$DSBULK" ]; then
# #     DSBULK="`which dsbulk`"
# #     if [ -z "$DSBULK" ]; then
# #         echo "Please set DSBULK_PATH variable to top-level path of DSBulk distribution"
# #         echo "  or add directory with dsbulk to PATH, like, 'PATH=...dsbulk-1.3.4/bin:\$PATH'"
# #         exit 1
# #     fi
# # fi

# ############################################
# # load the vertices
# ############################################
# echo "Loading vertices into the graph $DEST_KS"

# $DSBULK -k $DEST_KS -v Sensor -url Sensor.csv -header true
# $DSBULK -k $DEST_KS -v Tower -url Tower.csv -header true

# echo "Completed loading vertices into the graph $DEST_KS."

# ############################################
# # load the edges
# ############################################
# echo "Loading edges into the graph $DEST_KS"

# $DSBULK -k $DEST_KS -e send -from Sensor -to Sensor -url Sensor__send__Sensor.csv -header true
# $DSBULK -k $DEST_KS -e send -from Sensor -to Tower -url Sensor__send__Tower.csv -header true

# echo "Completed loading edges into the graph $DEST_KS."

# cd "$OLDWD"