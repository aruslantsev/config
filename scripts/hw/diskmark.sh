#!/bin/bash

# by Chocobo
# https://linuxmint.com.ru/viewtopic.php?t=7721

TESTFILE_PATH='./fiotest.tmp'
TESTFILE_SIZE='1000m'
TEST_LOOPS='5'

sync; sleep 3;
SEQ1MQ8T1R=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=SeqReadQ8 --bs=1m --iodepth=8 --rw=read | grep 'READ:' | awk '{print substr($3, 2, length($3)-3)}')
sync; sleep 3;
SEQ1MQ8T1W=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=SeqWriteQ8 --bs=1m --iodepth=8 --rw=write | grep 'WRITE:' | awk '{print substr($3, 2, length($3)-3)}')
echo " +----------------------------------------+"
printf " | %12s | %10s | %10s |\n" "Mode" "Read" "Write"
echo " +----------------------------------------+"
printf " | %12s | %10s | %10s |\n" "SEQ1MQ8T1" "$SEQ1MQ8T1R" "$SEQ1MQ8T1W"
echo " +----------------------------------------+"

sync; sleep 3;
SEQ1MQ1T1R=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=SeqReadQ1 --bs=1m --iodepth=1 --rw=read | grep 'READ:' | awk '{print substr($3, 2, length($3)-3)}')
sync; sleep 3;
SEQ1MQ1T1W=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=SeqWriteQ1 --bs=1m --iodepth=1 --rw=write | grep 'WRITE:' | awk '{print substr($3, 2, length($3)-3)}')
printf " | %12s | %10s | %10s |\n" "SEQ1MQ1T1" "$SEQ1MQ1T1R" "$SEQ1MQ1T1W"
echo " +----------------------------------------+"

sync; sleep 3;
RND4KQ32T1R=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=RandReadQ32 --bs=4k --iodepth=32 --rw=randread | grep 'READ:'| awk '{print substr($3, 2, length($3)-3)}')
sync; sleep 3;
RND4KQ32T1W=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=RandWriteQ32 --bs=4k --iodepth=32 --rw=randwrite | grep 'WRITE:'| awk '{print substr($3, 2, length($3)-3)}')
printf " | %12s | %10s | %10s |\n" "RND4KQ32T1" "$RND4KQ32T1R" "$RND4KQ32T1W"
echo " +----------------------------------------+"

sync; sleep 3;
RND4KQ1T1R=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=RandReadQ1 --bs=4k --iodepth=1 --rw=randread | grep 'READ:'| awk '{print substr($3, 2, length($3)-3)}')
sync; sleep 3;
RND4KQ1T1W=$(fio --loops=$TEST_LOOPS --size=$TESTFILE_SIZE --filename=$TESTFILE_PATH --ioengine=libaio --direct=1 --name=RandWriteQ1 --bs=4k --iodepth=1 --rw=randwrite | grep 'WRITE:'| awk '{print substr($3, 2, length($3)-3)}')
printf " | %12s | %10s | %10s |\n" "RND4KQ1T1" "$RND4KQ1T1R" "$RND4KQ1T1W"
echo " +----------------------------------------+"
