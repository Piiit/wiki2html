/* 
 * Copirait Lorenzo aka "The pointer" and Peter aka "The algorithm"
 * (C) (null)
 */


#include "symbol_table.h"
#include <stdlib.h>
#include "stdio.h"

static struct wiki_node* symbol_table = NULL;
static struct wiki_scope* global_scope = NULL;

/** SYMBOL TABLE STUFF HERE **/

struct wiki_node* symbol_table_init(void)
{
    if (symbol_table == NULL)
    {
        symbol_table = get_new_node();
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

struct wiki_node* get_new_node(void)
{
    struct wiki_node* node = malloc(sizeof(struct wiki_node));
    if (node)
    {
        node->lexeme = NULL;
        node->value = NULL;
        node->type = -1;
        node->next = NULL;
        node->scope = NULL;
    }
    return node;
}

void add_symbol(struct wiki_node* root, struct wiki_node* node, struct wiki_scope* scope)
{
    struct wiki_node* current = root;
    if (current->next != NULL)
        do {
            current = current->next;
        }
        while (current->next != NULL);
    current->next = node;
    /* Set extra node properties */
    set_scope(node, scope);
}

int symbol_table_length(struct wiki_node* root)
{
    struct wiki_node* cur_ptr = root;  
    int count=0;

    while(cur_ptr != NULL)
    {
       cur_ptr=cur_ptr->next;
       count++;
    }
    return(count);  
}

void print_symbol_table(struct wiki_node* root)
{
    struct wiki_node* current = root;
    if (current->next != NULL)
        do {
            current = current->next;
            char* scope = NULL;
            if (current->scope != NULL) current->scope->name;
            printf("%s -> %s (scope: %s)\n", current->lexeme, current->value, scope);
        }
        while (current->next != NULL);
    else
        printf("%s -> %s\n", current->lexeme, current->value);
}

/** SCOPE STUFF HERE **/

struct wiki_scope* scope_init(void)
{
    printf("Creating new scope\n");
    if (global_scope == NULL)
    {
        global_scope = get_new_scope_node("main");
    }
    return global_scope;
}

struct wiki_scope* get_new_scope_node(char* name)
{
    struct wiki_scope* node = malloc(sizeof(struct wiki_scope));
    if (node)
    {
        node->name = name;
        node->parent = NULL;
    }
    return node;
}

void scope_free(void)
{
    if (global_scope != NULL)
    {
        free(global_scope); 
        global_scope = NULL;
    }
}

void set_scope(struct wiki_node* node, struct wiki_scope* scope)
{
    if (node != NULL)
        node->scope = scope;
}