# # 	xsim sim_adc -nolog -wdb sim_adc.wdb -onfinish quit -t adc_nogui.tcl; \
echo "" > sim/adc/adc_test_results.txt
v="18'b110011000011111100"
for d in 0.7 1.3 2.3 ; do
    for n in $(seq 0 0.5 3)  ; do
        delay=$(echo $d + $n | bc)
        xelab -a -generic_top CLK_TO_DCO_DELAY=${delay} -generic_top ANALOG_DATA=${v} -nolog -prj sim/adc/adc.prj -L simprims_ver -s sim_adc xil_defaultlib.tb_adc xil_defaultlib.glbl;
        echo "Test with value ${v}, delay ${delay}" >> sim/adc/adc_test_results.txt
        ./axsim.sh >> sim/adc/adc_test_results.txt
    done
done

v="18'b101010101010101010"
for d in 0.7 1.3 2.3 ; do
    for n in $(seq 0 0.5 3)  ; do
        delay=$(echo $d + $n | bc)
        xelab -a -generic_top CLK_TO_DCO_DELAY=${delay} -generic_top ANALOG_DATA=${v} -nolog -prj sim/adc/adc.prj -L simprims_ver -s sim_adc xil_defaultlib.tb_adc xil_defaultlib.glbl;
        echo "Test with value ${v}, delay ${delay}" >> sim/adc/adc_test_results.txt
        ./axsim.sh >> sim/adc/adc_test_results.txt
    done
done

v="18'b010101010101010101"
for d in 0.7 1.3 2.3 ; do
    for n in $(seq 0 0.5 3)  ; do
        delay=$(echo $d + $n | bc)
        xelab -a -generic_top CLK_TO_DCO_DELAY=${delay} -generic_top ANALOG_DATA=${v} -nolog -prj sim/adc/adc.prj -L simprims_ver -s sim_adc xil_defaultlib.tb_adc xil_defaultlib.glbl;
        echo "Test with value ${v}, delay ${delay}" >> sim/adc/adc_test_results.txt
        ./axsim.sh >> sim/adc/adc_test_results.txt
    done
done

#        echo "DCO/DA/DB Delay set to ${delay}"
#        echo "Value ${v}"
