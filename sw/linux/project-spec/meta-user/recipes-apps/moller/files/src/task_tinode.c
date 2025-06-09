
#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

#include <zmq.h>

#include "moller.h"
#include "external/tinode_regs.h"

static void regmap_init(void);
static void regmap_close(void);
static int32_t ti_init(int32_t arg);

static int tinode_regmap_fd;
static volatile uint32_t *tinode_regmap;

void *tinode_thread(void *vargp)
{
	void *command;
	void *context = vargp;
	uint32_t cmd_msg[256];
	uint32_t addr;
	uint32_t data;
	int cmd_len;
	zmq_msg_t msg;

	printf("Starting TINode Thread\n");
	fflush(stdout);

	command = zmq_socket(context, ZMQ_REP);
	if(zmq_bind(command, "tcp://*:5557") != 0) {
		printf("Failed to Bind ZMQ to port 5557");
		return 0;
	}

	regmap_init();

	ti_init(0);

	while(1) {
		cmd_len = zmq_recv(command, &cmd_msg, sizeof(cmd_msg), ZMQ_NOBLOCK);
		if(cmd_len >= 0) {
			// currently just a simple read/write
			if(cmd_len == 12) {
				switch(cmd_msg[0]) {
				case 'w':
					addr = cmd_msg[1];
					data = cmd_msg[2];

					if(addr >= (TINODE_RANGE_BYTES/4)) {
						cmd_msg[0] = 'e';
						cmd_len = 4;
					} else {
						tinode_regmap[addr] = data;
						cmd_msg[0] = 'r';
						cmd_msg[1] = tinode_regmap[addr];
						cmd_len = 8;
					}
					break;

				case 'r':
					addr = cmd_msg[1];

					if(addr < (TINODE_RANGE_BYTES/4)) {
						cmd_msg[0] = 'r';
						cmd_msg[1] = tinode_regmap[addr];
						cmd_len = 8;
					} else {
						cmd_msg[0] = 'e';
						cmd_len = 4;
					}
					break;

				default:
					cmd_msg[0] = 'e';
					cmd_len = 4;
					break;
				}
			} else {
				cmd_msg[0] = 'e';
				cmd_len = 4;
			}

			zmq_send(command, cmd_msg, cmd_len, 0);
		}

		sched_yield();
	}

	regmap_close();

	pthread_exit(NULL);
}

static void regmap_init(void)
{
	tinode_regmap_fd = open("/dev/mem", O_RDWR | O_SYNC);
	if(tinode_regmap_fd == -1) {
		printf("TINODE /dev/mem access error\n");
		return;
	}

	tinode_regmap =
		(uint32_t *) mmap(NULL, TINODE_RANGE_BYTES, PROT_READ | PROT_WRITE,
				MAP_SHARED, tinode_regmap_fd,
				TINODE_DEFAULT_BASEADDR);
	if(!tinode_regmap) {
		printf("Failed to map TINODE registers\n");
		return;
	}
}

static void regmap_close(void)
{
	if(tinode_regmap) {
		munmap((void *)tinode_regmap, TINODE_RANGE_BYTES);
	}

	if(tinode_regmap_fd >= 0) {
		close(tinode_regmap_fd);
	}
}

static int32_t ti_init(int32_t arg)
{
	if(tinode_regmap) {
		printf("TINode Initialized\n");
		fflush(stdout);
		tinode_regmap[TINODE_REG_SYNC_SRC_EN] = 0x00000000;
		tinode_regmap[TINODE_REG_TRIG_SRC_EN] = 0x00000000;
		tinode_regmap[TINODE_REG_BUSY_SRC_EN] = 0x00000000;

		tinode_regmap[TINODE_REG_FIBER_EN] = 0x000005FF;

		tinode_regmap[TINODE_REG_CLOCK_SRC] = 0x00000002;
		usleep(3000);   //ClkDelayReady is reset on clock settings

		tinode_regmap[TINODE_REG_VME_RESET_INT] = 0x00000100;
		usleep(3000);
		tinode_regmap[TINODE_REG_VME_RESET_INT] = 0x00000200;
		usleep(3000);
		
		// Added the IOdelayReset
		tinode_regmap[TINODE_REG_VME_RESET_INT] = 0x00004000;
		usleep(30000);
		// Sync auto alignment
		tinode_regmap[TINODE_REG_VME_RESET_INT] = 0x00001800;
		usleep(30000);

		tinode_regmap[TINODE_REG_SYNC_SRC_EN] = 0x00000002;

		tinode_regmap[TINODE_REG_SYNC_GEN_DELAY] = 0x54;
		tinode_regmap[TINODE_REG_SYNC_WIDTH] = 0x2f;
		tinode_regmap[TINODE_REG_TRIG_DELAY_WIDTH] = 0x0F0000F0;

		tinode_regmap[TINODE_REG_TRIG_PRESCALE] = 0x00000000;
		tinode_regmap[TINODE_REG_BLOCK_TH] = 0x00000001;
		tinode_regmap[TINODE_REG_CRATE_ID] = 0xDA;

		// Go
		//tinode_regmap[TINODE_REG_TRIG_SRC_EN] = 0x00000012;

		// Stop
		// tinode_regmap[TINODE_REG_TRIG_SRC_EN] =      0x00000000
	}

}
