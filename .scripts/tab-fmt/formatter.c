#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdint.h>

#define STR_BUFF_LEN 255
#define MAX_LINES UINT8_MAX

#define MAX(a, b) (a > b) ? a : b;

typedef struct {
	uint8_t nFields, nRecords;
	char cells[MAX_LINES][MAX_LINES][STR_BUFF_LEN];
} Table;

void trim(char* str, char* trimmed) {
	uint8_t beg = 0, end = strlen(str)-1;
	while (isblank(str[beg++]));
	while (isblank(str[end--]));
	uint8_t len = ++end - --beg + 1;
	strncpy(trimmed, str+beg, len);
	trimmed[len] = '\0';
}

void padLeft(char* str, char ch, uint8_t N) {
	uint8_t len = strlen(str);
	if (len >= N) return;
	str[N] = '\0';
	int i = N - 1, diff = N - len;
	for (; i >= diff; i--) str[i] = str[i - diff];
	for (; i >=    0; i--) str[i] = ch;
}

void padRight(char* str, char ch, uint8_t N) {
	uint8_t len = strlen(str);
	if (len >= N) return;
	str[N] = '\0';
	for (int i = len; i < N; i++) str[i] = ch;
}

void alignLeft(char* str, uint8_t N) {
	padRight(str, ' ', N+1);
	padLeft (str, ' ', N+2);
}

void alignRight(char* str, uint8_t N) {
	padLeft (str, ' ', N+1);
	padRight(str, ' ', N+2);
}

void alignCenter(char* str, uint8_t N) {
	uint8_t len = strlen(str);
	int diff = N - len;
	uint8_t paddingLeft = diff / 2;
	uint8_t paddingRight = diff / 2 + (diff%2);
	padLeft (str, ' ', len+paddingLeft+1);
	padRight(str, ' ', N+2);
}

void addRecord(Table* tab, char* line) {
	uint8_t row = tab->nRecords, col = 0;
	char* token = strtok(line, "|");
	do {
		strncpy(tab->cells[row][col], token, strlen(token));
		trim(tab->cells[row][col], tab->cells[row][col]);
		col++;
	} while ((token = strtok(NULL, "|")));
	tab->nRecords++;
	tab->nFields = MAX(tab->nFields, col);
}

void alignColumns(Table* tab) {
	for (uint8_t col = 0; col < tab->nFields; col++) {
		uint8_t width = 0;
		for (uint8_t row = 0; row < tab->nRecords; row++)
			width = MAX(strlen(tab->cells[row][col]), width);

		char* hrule = tab->cells[1][col];
		int align = ((hrule[strlen(hrule)-1] == ':') << 1) | (hrule[0] == ':');
		void (*alignment)(char*, uint8_t);
		switch (align) {
			case 0: // no ':' specifiers
			case 1: // left align
				alignment = alignLeft;
				padRight(tab->cells[1][col], '-', width + 2);
				break;
			case 2: // right align
				alignment = alignRight;
				padLeft(tab->cells[1][col], '-', width + 2);
				break;
			case 3: // center align
				alignment = alignCenter;
				*strrchr(hrule, ':') = '\0';
				padRight(hrule+1, '-', width+1);
				hrule[width+1] = ':';
				break;
		}
		// header row is always centre aligned
		alignCenter(tab->cells[0][col], width);
		for (uint8_t row = 2; row < tab->nRecords; row++)
			alignment(tab->cells[row][col], width);
	}
}

void printTable(Table* tab) {
	for (uint8_t i = 0; i < tab->nRecords; i++) {
		printf("|");
		for (uint8_t j = 0; j < tab->nFields; j++) printf("%s|", tab->cells[i][j]);
		printf("\n");
	}
}

int main(int argc, char* argv[]) {
	char* input = (char*) malloc(STR_BUFF_LEN * sizeof(char));
	Table* table = (Table*) malloc(sizeof(Table));
	table->nFields = table->nRecords = 0;
	while (fgets(input, STR_BUFF_LEN, stdin)) {
		if (strlen(input) <= 1) break;
		input[strlen(input) - 1] = '\0';
		addRecord(table, input);
	}
	alignColumns(table);
	printTable(table);

	if (input) free(input);
	free(table);
	return EXIT_SUCCESS;
}
