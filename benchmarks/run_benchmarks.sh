#!/bin/zsh

FILES=`cat TESTS`

echo "Running each test ${1} times"

# Note to self: use python next time

# How many times bechmarks run in the same process 
N=10

# How many times bechmarks run (setting up a new process)
M=$1


# First run ocaml scripts (rather suboptimal way)
echo "Running ocamlc and ocamlopt programs..."

for i in $(seq 1 $M)
do
    ./ocaml/main $N > ocamlc_bench_$i.txt    
    ./ocaml/mainopt $N > ocamlopt_bench_$i.txt
done
    
echo "Running CertiCoq programs..."
printf "%10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s %10s \n" "Benchmark" "CertiCoq" "Ratio" "Dev" "CertiCoqO" "Ratio" "Dev" "CertiCoqL" "Ratio" "Dev" "ocamlc" "Ratio" "Dev" "ocamlopt" "Ratio" "Dev"



for f in $FILES
do

    sumanf=0.0
    sumopt=0.0
    sumoptll=0.0
    sumocamlc=0.0
    sumocamlopt=0.0

    sumsqanf=0.0
    sumsqopt=0.0
    sumsqoptll=0.0
    sumsqocamlc=0.0
    sumsqocamlopt=0.0
    
    for i in $(seq 1 $M)
    do

	# Find ANF time    
	anf=$(./${f} ${N} | awk -v N=${N} '/Time taken/ {print ($5 / N) }')
	# Find OPT time
	opt=$(./${f}_opt ${N} | awk -v N=${N} '/Time taken/ {print ($5 / N) }')
	# Find OPT time with non-selective lambda lifting
	optll=$(./${f}_opt_ll ${N} | awk -v N=${N} '/Time taken/ {print ($5 / N) }')
	# Find OCamlc time (assumes ocaml programs run for N times)
	ocamlc=`awk -v N=${N} -v pat="${f}" '$0 ~ pat {print ($4 / N) }' ocamlc_bench_$i.txt`
	# Find OCamlopt time
	ocamlopt=`awk -v N=${N} -v pat="${f}" '$0 ~ pat {print ($4 / N)}' ocamlopt_bench_$i.txt`


	# do sums
	sumanf=`awk -v TOTAL=${sumanf} -v NEW=${anf} 'BEGIN { print  ( TOTAL + NEW ) }'`
	sumopt=`awk -v TOTAL=${sumopt} -v NEW=${opt} 'BEGIN { print  ( TOTAL + NEW ) }'`
	sumoptll=`awk -v TOTAL=${sumoptll} -v NEW=${optll} 'BEGIN { print  ( TOTAL + NEW ) }'`
	sumocamlc=`awk -v TOTAL=${sumocamlc} -v NEW=${ocamlc} 'BEGIN { print  ( TOTAL + NEW ) }'`
	sumocamlopt=`awk -v TOTAL=${sumocamlopt} -v NEW=${ocamlopt} 'BEGIN { print  ( TOTAL + NEW ) }'`

	# do sums of squares
	sumsqanf=`awk -v TOTAL=${sumsqanf} -v NEW=${anf} 'BEGIN { print  ( TOTAL + NEW*NEW ) }'`
	sumsqopt=`awk -v TOTAL=${sumsqopt} -v NEW=${opt} 'BEGIN { print  ( TOTAL + NEW*NEW ) }'`
	sumsqoptll=`awk -v TOTAL=${sumsqoptll} -v NEW=${optll} 'BEGIN { print  ( TOTAL + NEW*NEW ) }'`
	sumsqocamlc=`awk -v TOTAL=${sumsqocamlc} -v NEW=${ocamlc} 'BEGIN { print  ( TOTAL + NEW*NEW ) }'`
	sumsqocamlopt=`awk -v TOTAL=${sumsqocamlopt} -v NEW=${ocamlopt} 'BEGIN { print  ( TOTAL + NEW*NEW ) }'`


    done

    # Find mean
    timeanf=`awk -v TOTAL=${sumanf} -v M=${M} 'BEGIN { print  ( TOTAL / M ) }'`
    timeopt=`awk -v TOTAL=${sumopt} -v M=${M} 'BEGIN { print  ( TOTAL / M ) }'`
    timeoptll=`awk -v TOTAL=${sumoptll} -v M=${M} 'BEGIN { print  ( TOTAL / M ) }'`
    timeocamlc=`awk -v TOTAL=${sumocamlc} -v M=${M} 'BEGIN { print  ( TOTAL / M ) }'`
    timeocamlopt=`awk -v TOTAL=${sumocamlopt} -v M=${M} 'BEGIN { print  ( TOTAL / M ) }'`

    # Find standard deviation
    devanf=`awk -v MEAN=${timeanf} -v SUMSQ=${sumsqanf} -v M=${M} 'BEGIN { print  ( sqrt ( sqrt ( ( (SUMSQ / M) - MEAN * MEAN) ^ 2 ) ) ) }'`
    devopt=`awk -v MEAN=${timeopt} -v SUMSQ=${sumsqopt} -v M=${M} 'BEGIN { print  ( sqrt ( sqrt ( ( (SUMSQ / M) - MEAN * MEAN) ^ 2 ) ) ) }'`
    devoptll=`awk -v MEAN=${timeoptll} -v SUMSQ=${sumsqoptll} -v M=${M} 'BEGIN { print  ( sqrt ( sqrt ( ( (SUMSQ / M) - MEAN * MEAN) ^ 2 ) ) ) }'`
    devocamlc=`awk -v MEAN=${timeocamlc} -v SUMSQ=${sumsqocamlc} -v M=${M} 'BEGIN { print  ( sqrt ( sqrt ( ( (SUMSQ / M) - MEAN * MEAN) ^ 2 ) ) ) }'`
    devocamlopt=`awk -v MEAN=${timeocamlopt} -v SUMSQ=${sumsqocamlopt} -v M=${M} 'BEGIN { print  ( sqrt ( sqrt ( ( (SUMSQ / M) - MEAN * MEAN) ^ 2 ) ) ) }'`

    
    # Normalize mean
    ratioanf=`awk -v ANF=${timeanf} -v OPT=${timeanf} 'BEGIN { print  ( OPT / ANF ) }'`
    ratioopt=`awk -v ANF=${timeanf} -v OPT=${timeopt} 'BEGIN { print  ( OPT / ANF ) }'`
    ratiooptll=`awk -v ANF=${timeanf} -v OPT=${timeoptll} 'BEGIN { print  ( OPT / ANF ) }'`
    ratioocamlc=`awk -v ANF=${timeanf} -v OPT=${timeocamlc} 'BEGIN { print  ( OPT / ANF ) }'`
    ratioocamlopt=`awk -v ANF=${timeanf} -v OPT=${timeocamlopt} 'BEGIN { print  ( OPT / ANF ) }'`

    # Normalize standard dev
    rdevanf=`awk -v ANF=${timeanf} -v OPT=${devanf} 'BEGIN { print  ( OPT / ANF ) }'`
    rdevopt=`awk -v ANF=${timeanf} -v OPT=${devopt} 'BEGIN { print  ( OPT / ANF ) }'`
    rdevoptll=`awk -v ANF=${timeanf} -v OPT=${devoptll} 'BEGIN { print  ( OPT / ANF ) }'`
    rdevocamlc=`awk -v ANF=${timeanf} -v OPT=${devocamlc} 'BEGIN { print  ( OPT / ANF ) }'`
    rdevocamlopt=`awk -v ANF=${timeanf} -v OPT=${devocamlopt} 'BEGIN { print  ( OPT / ANF ) }'`

    # rdevanf=$devanf
    # rdevopt=$devopt
    # rdevoptll=$devoptll
    # rdevocamlc=$devocamlc
    # rdevocamlopt=$devocamlopt

    
    if [ "${f}" = "color" ]; then # Because ocaml code does not compile
	printf "%10s   %.3f      %.3f      %.3f      %.3f      %.3f      %.3f      %.3f      %.3f      %.3f        -         -         -         -        -         - \n" "${f}" "$timeanf" "$ratioanf" "$rdevanf" "$timeopt" "$ratioopt" "$rdevopt" "$timeoptll" "$ratiooptll" "$rdevoptll"
    else

	printf "%10s   %.3f      %.3f      %.3f      %.3f      %.3f      %.3f      %.3f      %.3f      %.3f      %.3f   %.3f      %.3f      %.3f      %.3f      %.3f \n" "${f}" "$timeanf" "$ratioanf" "$rdevanf" "$timeopt" "$ratioopt" "$rdevopt" "$timeoptll" "$ratiooptll" "$rdevoptll"  "$timeocamlc" "$ratioocamlc" "$rdevocamlc" "$timeocamlopt" "$ratioocamlopt" "$rdevocamlopt"

    fi
done
