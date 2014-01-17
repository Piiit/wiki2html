/* 
 * Copirait Lorenzo aka "The pointer" or "Ghost <!> buster" and Peter aka "The algorithm"
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

void add_symbol(struct wiki_node* symbol, struct wiki_scope* scope)
{
    if (scope->local_symbol_table == NULL)
    {
        /* Create a fresh symbol table entry */
        scope->local_symbol_table = symbol;
    }
    else 
    {
        struct wiki_node* current = scope->local_symbol_table;
        if (current->next != NULL)
            do {
                current = current->next;
            }
            while (current->next != NULL);
        current->next = symbol;
    }
    /* Set extra node properties */
    set_scope(symbol, scope);
}

struct wiki_node* scan_symbol_table(char* identifier, struct wiki_scope* scope)
{
    struct wiki_node* current = scope->local_symbol_table;
    if (current == NULL)
        return NULL;
    do {
        /* If the symbol is in the current scope, matches the name and it is a variable, then perfect return it! */
        if (current->scope == scope &&
        strcmp(current->lexeme, identifier) == 0 &&
        current->type == TYPE_VARIABLE)
        {
            return current;
        }
        current = current->next;
    }
    while (current != NULL);
    return NULL;
}

struct wiki_node* find_identifier(char* identifier, struct wiki_scope* scope)
{
    struct wiki_scope* current_scope = scope;
    do {
        struct wiki_node* abcd = scan_symbol_table(identifier, current_scope);
        if (abcd != NULL)
            return abcd;

        current_scope = current_scope->parent;
    }
    while (current_scope != NULL);
    /* We did not find anything */
    return NULL;
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
    return count;
}

void print_symbol_table(struct wiki_scope* scope)
{
    struct wiki_node* current = scope->local_symbol_table;
    if (current == NULL)
        return;
    do {
        fprintf(stderr, "%s -> %s (scope: %s; stack: ", current->lexeme, current->value, current->scope->name);
        print_scope_stack(scope);
        fprintf(stderr, ")\n");
        current = current->next;
    }
    while (current != NULL);
}

/** SCOPE STUFF HERE **/

struct wiki_scope* scope_init(void)
{
    fprintf(stderr, "Creating new scope\n");
    if (global_scope == NULL)
    {
        global_scope = get_new_scope_node("main", NULL);
    }
    return global_scope;
}

struct wiki_scope* get_new_scope_node(char* name, struct wiki_scope* parent)
{
    struct wiki_scope* node = malloc(sizeof(struct wiki_scope));
    if (node != NULL)
    {
        node->name = name;
        node->parent = parent;
        node->local_symbol_table = NULL;
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
    if (node != NULL) {
        fprintf(stderr, "Setting scope %s to node %s\n", scope->name, node->lexeme);
        node->scope = scope;
    }
}

int scope_depth(struct wiki_scope* deepest)
{
    struct wiki_scope* cur_ptr = deepest;  
    int count=0;

    while(cur_ptr != NULL)
    {
       cur_ptr=cur_ptr->parent;
       count++;
    }
    return count;
}

void print_scope_stack(struct wiki_scope* scope)
{
    struct wiki_scope* cur_ptr = scope;
    int count=0;

    while(cur_ptr != NULL)
    {
       fprintf(stderr, "->%s", cur_ptr->name);
       cur_ptr=cur_ptr->parent;
       count++;
    }

    fprintf(stderr, " (depth %d)", count);
}
