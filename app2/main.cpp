#include <stdio.h>
#include <stdlib.h>
#include "app1.h"

int
main()
{
	int a = one();
	int b = two();
	int c = three();

	printf("Easy as %d, %d, %d!\n", a, b, c);

	return 0;
}
