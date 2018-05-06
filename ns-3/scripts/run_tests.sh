#!/bin/bash

TIME=100

cd ..

for ERR_RATE in `seq 0 0.1 0.5`
do
    echo "Running state measurements ERR_RATE=${ERR_RATE}"
    cDelay=4960
    pDelay=5000
    frequency=10	
    LD_LIBRARY_PATH=/usr/local/lib NS_LOG=nfd.PIT ./waf --run="thunks -retx=10ms -cDataDelay=${cDelay} -pDataDelay=${pDelay} -time=${TIME}s -errRate=${ERR_RATE} -frequency=${frequency}" &> ./scripts/logs/state_loss_thunks:${ERR_RATE}:${cDelay}:${pDelay}.log

    cDelay=1000
    pDelay=5000
    frequency=10	
    LD_LIBRARY_PATH=/usr/local/lib NS_LOG=nfd.PIT ./waf --run="thunks -retx=1000ms -cDataDelay=${cDelay} -pDataDelay=${pDelay} -time=${TIME}s -errRate=${ERR_RATE} -frequency=${frequency}" &> ./scripts/logs/state_loss_net:${ERR_RATE}:${cDelay}:${pDelay}.log
done

exit

for ERR_RATE in `seq 0 0.005 0.5`
do
    echo "Running ERR_RATE=${ERR_RATE}"
    #thunks, manually remove the RTT
    cDelay=4960
    pDelay=5000
    LD_LIBRARY_PATH=/usr/local/lib NS_LOG=ndn.ProducerThunks:ndn.ConsumerThunks ./waf --run="thunks -retx=10ms -cDataDelay=${cDelay} -pDataDelay=${pDelay} -time=${TIME}s -errRate=${ERR_RATE}" &> ./scripts/logs/thunks:${ERR_RATE}:${cDelay}:${pDelay}.log


    #net time
    cDelay=1000
    pDelay=5000
    LD_LIBRARY_PATH=/usr/local/lib NS_LOG=ndn.ConsumerTimers:ndn.ProducerThunks:ndn.ConsumerThunks ./waf --run="thunks -retx=1000ms -cDataDelay=${cDelay} -pDataDelay=${pDelay} -time=${TIME}s -errRate=${ERR_RATE}" &> ./scripts/logs/net:${ERR_RATE}:${cDelay}:${pDelay}.log
done

ERR_RATE=0
for delay in `seq 1000 100 10000`
do
    pDelay=$delay
    cDelay=$delay
    let cDelay-=40 
    echo $cDelay
    echo "Running Delay=${delay}"
    
#thunks, manually remove the RTT
    LD_LIBRARY_PATH=/usr/local/lib NS_LOG=ndn.ProducerThunks:ndn.ConsumerThunks ./waf --run="thunks -retx=10ms -cDataDelay=${cDelay} -pDataDelay=${pDelay} -time=${TIME}s -errRate=${ERR_RATE}" &> ./scripts/logs/pthunks:${ERR_RATE}:${cDelay}:${pDelay}.log

    #net time
    cDelay=1000
    pDelay=$delay
    LD_LIBRARY_PATH=/usr/local/lib NS_LOG=ndn.ProducerThunks:ndn.ConsumerThunks ./waf --run="thunks -retx=1000ms -cDataDelay=${cDelay} -pDataDelay=${pDelay} -time=${TIME}s -errRate=${ERR_RATE}" &> ./scripts/logs/pnet:${ERR_RATE}:${cDelay}:${pDelay}.log
done

cd scripts

./analyse.sh
./generate_graphs.sh
