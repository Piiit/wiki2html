#include "symbol_table.h"
#include <stdlib.h>
#include "stdio.h"

static struct wiki_node* symbol_table = NULL;
static struct wiki_scope* global_scope = NULL;

struct wiki_node* symbol_table_init(void)
{
    if (symbol_table == NULL)
    {
        symbol_table = malloc(sizeof(symbol_table));
    }
    return symbol_table;
}

void symbol_table_free()
{
    if (symbol_table != NULL)
    {
        free(symbol_table); 
        symbol_table = NULL;
    }
}