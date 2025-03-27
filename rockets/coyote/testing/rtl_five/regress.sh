#!/bin/sh

#################################################################
# Different testsuites
PARAM_NUM=6
TEST_SUITE_LIST=("TEST_TEST"
                 "TEST_LOOPBACK"
                 "TEST_REORDER_LOOPBACK"
                 "TEST_REORDER_ALL"
                 "TEST_REORDER_SNEAK_BNN"
                )

#name   rocket#Num      #needs recompile?        #compile switchs       BNN rocket#NUM  BNN bench
TEST_TEST=(  
"bsg_rocket_loopback"   "0"     "N"     ""      ""      ""
          )

TEST_MANYCORE_LOOPBACK=(
"bsg_rocket_manycore_loopback"  "0"     "Y"     "bsg_manycore_rocket_index=0"   ""      ""
)

TEST_LOOPBACK=(  
"bsg_rocket_loopback"           "0"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "1"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "2"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "3"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "4"     "N"     ""                              ""      ""
"bsg_rocket_manycore_loopback"  "0"     "Y"     "bsg_manycore_rocket_index=0"   ""      ""
"bsg_rocket_manycore_loopback"  "1"     "Y"     "bsg_manycore_rocket_index=1"   ""      ""
"bsg_rocket_manycore_loopback"  "2"     "Y"     "bsg_manycore_rocket_index=2"   ""      ""
"bsg_rocket_manycore_loopback"  "3"     "Y"     "bsg_manycore_rocket_index=3"   ""      ""
"bnn_loopback"                  "4"     "N"     ""
            )

TEST_REORDER_LOOPBACK=(  
"bsg_rocket_loopback"           "0"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "1"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "2"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "3"     "N"     ""                              ""      ""
"bsg_rocket_loopback"           "4"     "N"     ""                              ""      ""
"bsg_rocket_manycore_loopback"  "0"     "Y"     "bsg_manycore_rocket_index=0"   ""      ""
"bsg_rocket_manycore_loopback"  "1"     "Y"     "bsg_manycore_rocket_index=1"   ""      ""
"bsg_rocket_manycore_loopback"  "3"     "Y"     "bsg_manycore_rocket_index=2"   ""      ""
"bsg_rocket_manycore_loopback"  "4"     "Y"     "bsg_manycore_rocket_index=3"   ""      ""
"bnn_loopback"                  "2"     "N"     ""                              ""      ""
            )
TEST_REORDER_SNEAK_BNN=( 
"manycore_streambuf_layer_1"     "0"    "N"     ""      "2"  "bnn_layer_1_sneakpath"
"manycore_streambuf_layer_2"     "0"    "N"     ""      "2"  "bnn_layer_2_sneakpath"
"manycore_streambuf_layer_3"     "0"    "N"     ""      "2"  "bnn_layer_3_sneakpath"
"manycore_streambuf_layer_4"     "0"    "N"     ""      "2"  "bnn_layer_4_sneakpath"
"manycore_streambuf_layer_5"     "0"    "N"     ""      "2"  "bnn_layer_5_sneakpath"
"manycore_streambuf_layer_6"     "0"    "N"     ""      "2"  "bnn_layer_6_sneakpath"
"manycore_streambuf_layer_7"     "0"    "N"     ""      "2"  "bnn_layer_7_sneakpath"
"manycore_streambuf_layer_8"     "0"    "N"     ""      "2"  "bnn_layer_8_sneakpath"
"manycore_streambuf_single_image" "0"    "N"     ""      "2"  "bnn_sneakpath"
)
TEST_REORDER_ALL=( 
"${TEST_REORDER_LOOPBACK[@]}"
"${TEST_REORDER_SNEAK_BNN[@]}"
"bsg_rocket_manycore_2tile_loopback"     "0"    "N"     ""  ""  ""
"bsg_rocket_manycore_mc_congestion_load" "0"    "Y"     ""  ""  ""
"bsg_rocket_manycore_remote_load"        "0"    "Y"     ""  ""  ""
"bsg_rocket_manycore_rocc_basher"        "0"    "Y"     ""  ""  ""
"bsg_rocket_manycore_token_queue"        "0"    "N"     ""  ""  ""
)
#################################################################
# funcitons to investigate the test suites
function print_header( ){
       sep="\t"
       echo    "============================================================================"
       echo -e "benchmark#Name${sep}rocket#Num${sep}Needs recompile?${sep}#compile switchs${sep}#bnn rocket#NUM${sep}#bnn bench" 
}

function print_entry( ){
       local -i test_index=$(( $2 * ${PARAM_NUM} )) 
       local -a test_suite=("${!1}")

       echo -e ${test_suite[  $((  $test_index + 0 )) ]}   "${sep}"\
       ${test_suite[  $((  $test_index + 1 )) ]}           "${sep}"\
       ${test_suite[  $((  $test_index + 2 )) ]}           "${sep}"\
       ${test_suite[  $((  $test_index + 3 )) ]}           "${sep}"\
       ${test_suite[  $((  $test_index + 4 )) ]}           "${sep}"\
       ${test_suite[  $((  $test_index + 5 )) ]}           
        
}

function print_testsuite( ){
        local -a        test_suite=("${!1}")
        local           test_num=$((    ${#test_suite[*]} / ${PARAM_NUM}  ))

        print_header

        for ((i=0;i<$test_num;i++)); do
                print_entry     test_suite[@] $i
        done
}

function print_all_suites( ){
        echo "Avaliable test suites"

        for suite in ${TEST_SUITE_LIST[@]}; do
                echo                    ""
                echo                    "${suite}:"
                print_testsuite         ${suite}[@]
        done
}

function print_help( ){
        echo    "Usage:    "
        echo    "       $0 --run <test_suit> [ --design <design name> ]"
        echo    "       $0 --list_all   : list avaliabe test suites"
        echo    "       $0 --help       : display this message"
} 
function create_log_dir( ){
        local   dir_name=$( date +%F_%H-%M )
        mkdir   ${dir_name}
        echo    ${dir_name}
}
#################################################################
function get_need_recompile( ){
       local test_index=$(( $2 * ${PARAM_NUM} ))      
       local test_suite=("${!1}")

       echo ${test_suite[  $((  $test_index + 2 )) ]}   
}

function get_comp_opt( ){
       local test_index=$(( $2 * ${PARAM_NUM} ))      
       local test_suite=("${!1}")

       echo ${test_suite[  $((  $test_index + 3 )) ]}   
}

function get_test_name( ){
       local test_index=$(( $2 * ${PARAM_NUM} ))      
       local test_suite=("${!1}")

       echo ${test_suite[  $((  $test_index + 0 )) ]}   
}

function get_rocket_num( ){
       local test_index=$(( $2 * ${PARAM_NUM} ))      
       local test_suite=("${!1}")

       echo ${test_suite[  $((  $test_index + 1 )) ]}   
}

function get_bnn_rocket_num( ){
       local test_index=$(( $2 * ${PARAM_NUM} ))      
       local test_suite=("${!1}")

       echo ${test_suite[  $((  $test_index + 4 )) ]}   
}

function get_bnn_bench( ){
       local test_index=$(( $2 * ${PARAM_NUM} ))      
       local test_suite=("${!1}")

       echo ${test_suite[  $((  $test_index + 5 )) ]}   
}

function clean_test( ){
        make -C ../rtl_five clean_$1 BENCHMARK_0=$1 &> /dev/null
}

function recompile( ){
        clean_test  $1 
        make -C ../rtl_five BENCHMARK_0=$1 $2 $(readlink -m ../../../../common/benchmark/$1.riscv.hex) &> /dev/null
}

function run_testsuite(){
        local test_suite=("${!1}")
        local test_num=$((    ${#test_suite[*]} / ${PARAM_NUM}  ))
        local design_name=$2
        local log_dir=$(create_log_dir )

        for ((i=0; i<${test_num};i++)); do
                local name=$(get_test_name test_suite[@]  $i)
                local rocket_num=$(get_rocket_num  test_suite[@] $i)
                local comp_opt=$(get_comp_opt test_suite[@] $i)
                local bnn_rocket_num=$(get_bnn_rocket_num  test_suite[@] $i)
                local bnn_bench=$(get_bnn_bench  test_suite[@] $i)
                       
                local log_file="${log_dir}/${name}_rocket_${rocket_num}.log"

                print_header    

                if [ $(get_need_recompile test_suite[@] $i) == "Y" ]; then
                        echo "recompiling ... " 
                        clean_test      $name  
                        recompile       $name  $comp_opt 
                fi

                echo "$(print_entry test_suite[@] $i)"         
                echo "on design: [$design_name]"

                (time make run BENCHMARK_${rocket_num}=$name             \
                              BENCHMARK_${bnn_rocket_num}=$bnn_bench    \
                              ROCKET_NAME=$design_name) &> ${log_file}

	        grep            "==>\|PASS"  ${log_file}
                make            clean      &> /dev/null 
        done 
}
##################################################################
if (($# < 1)) ; then 
        print_help
        exit 1
fi

POSITIONAL=()
TEST_SUITE="TEST_TEST"
DESIGN_NAME="certus_soc"

while (( $# > 0 )); do
        KEY="$1"
        case    $KEY    in 
                --help)
                        print_help
                        shift
                        exit 0
                ;;
                --list_all)      
                        print_all_suites
                        shift
                        exit 0
                ;;
                --run)
                        TEST_SUITE=${2}
                        shift   #shift the option
                        shift   #shift the value
                ;;
                --design)
                        DESIGN_NAME=${2}
                        shift   #shift the option
                        shift   #shift the value
                ;;
                *)
                        POSITIONAL+=("$1")
                        print_help
                        shift
                        exit 0
                ;;
esac
done

run_testsuite          ${TEST_SUITE}[@] ${DESIGN_NAME}
