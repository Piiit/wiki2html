#include "symbol_table.h"
#include <stdlib.h>
#include "stdio.h"

static struct wiki_node* symbol_table = NULL;
static struct wiki_scope* global_scope = NULL;

int symbol_table_init(struct wiki_node* node)
{
    if (symbol_table == NULL)
    {
        symbol_table = malloc(sizeof(symbol_table));
        if (symbol_table == NULL) {
            return 1;
        }
    }
    node = symbol_table;
        node->lexeme = "";
    return 0;
}

void symbol_table_free()
{
    if (symbol_table != NULL)
    {
        free(symbol_table); 
        symbol_table = NULL;
    }
}