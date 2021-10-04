Please complete your sfp.v file in git's hw/w1/hw1/verilog/ path.

-In: 4-bit, out: 16-bit

-Control bits: acc, relu, reset

-If reset == 1, internal latch “psum_q” becomes zero

-If acc == 1, psum_q will be updated with “psum_q + In” in the next rising edge

-If relu == 1 and psum_q is negative number, psum_q will be updated to be zero in the next rising edge

-out port is just connected to the psum_q

 

-Sample vcd file is attached in git.

-sfp_tb.v file is also attached. Once you run sfp_tb.v file with your completed sfp.v file, the output waveform should be identical to sample vcd file.

-Attach your sfp.v file screenshot (no need to attach sfp_tb.v) and your completed waveform with either pdf or graphic files.




Regarding HW1, there were a few common questions. 

Please read follows:

1. In the sfp_tb.v file, there is no "expected_out" generator implemented.

    So, the expected_out signal should be just 0. Please ignore it.

    You do not need to create the "expected_out" generator.

2. When you compile, a command "iveri sfp.v" won't wok.

    You should generate filelist file first, and then please run "iveri filelist".

3. If you are not familiar with vi editor or gvim, please type "gedit filename".

    Once "gedit" is open, you can write a text like a microsoft word.

4. You can use either synchronous or asynchronous reset whatever you like.

    The example code for mac was synchronous reset.

5. If the computed results are correct, your waveform does not need to be perfectly identical to the sample vcd file.