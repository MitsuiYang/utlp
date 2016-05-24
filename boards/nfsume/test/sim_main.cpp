#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtestbench.h"

#include <stdbool.h>
#include <unistd.h>
//#include "axis.h"


#define SFP_CLK               (64/2)        // 6.4 ns (156.25 MHz)
#define PCIE_REF_CLK          (40/2)        // 4 ns (250 MHz)

#define WAVE_FILE_NAME        "wave.vcd"
#define SIM_TIME_RESOLUTION   "100 ps"
#define SIM_TIME              1000000       // 100 us

#define __packed    __attribute__((__packed__))

//static int debug = 1;

static uint64_t t = 0;


/*
 * tick: a tick
 */
static inline void tick(Vtestbench *sim, VerilatedVcdC *tfp)
{
	++t;
	sim->eval();
	tfp->dump(t);
}

/*
 * time_wait
 */
static inline void time_wait(Vtestbench *sim, VerilatedVcdC *tfp, uint32_t n)
{
	t += n;
	sim->eval();
	tfp->dump(t);
}

/*
 * main
 */
int main(int argc, char **argv)
{
	int ret;

	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);

	VerilatedVcdC *tfp = new VerilatedVcdC;
	tfp->spTrace()->set_time_resolution(SIM_TIME_RESOLUTION);
	Vtestbench *sim = new Vtestbench;
	sim->trace(tfp, 99);
	tfp->open(WAVE_FILE_NAME);

	sim->cold_reset = 1;
	sim->SFP_CLK_P = 0;
	sim->user_clk = 0;

	while (!Verilated::gotFinish()) {
		if ((t % SFP_CLK) == 0)
			sim->SFP_CLK_P = !sim->SFP_CLK_P;

		if ((t % PCIE_REF_CLK) == 0)
			sim->user_clk = !sim->user_clk;
		
		if (t > SFP_CLK * 8)
			sim->cold_reset = 0;

		if (t > SIM_TIME)
			break;

		tick(sim, tfp);
	}

	tfp->close();
	sim->final();

	return 0;
}

