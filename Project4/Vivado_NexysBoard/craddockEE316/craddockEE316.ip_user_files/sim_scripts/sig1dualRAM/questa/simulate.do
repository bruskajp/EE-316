onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib sig1dualRAM_opt

do {wave.do}

view wave
view structure
view signals

do {sig1dualRAM.udo}

run -all

quit -force
