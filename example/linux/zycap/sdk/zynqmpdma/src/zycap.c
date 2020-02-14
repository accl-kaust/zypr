#include "lib/xzdma.h"

XZDma_Config Config =
  {
	 0,
	 0x00000000a0000000,
	 0 /* 0 = GDMA, 1 = ADMA */
  };

int main() {
	XZDma ZDma;
	int Status = XZDma_CfgInitialize(&ZDma, &Config, Config.BaseAddress);
	printf("Status: %d", Status);
	return 0;
}
