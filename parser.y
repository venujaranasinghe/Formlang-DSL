%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;

int has_errors = 0;  // Global flag to track if any errors occurred

/* Enhanced error reporting using yylineno */
void yyerror(const char *s) {
  extern char *yytext;  /* Current token text from flex */
  
  has_errors = 1;  // Set error flag
  
  if (strstr(s, "syntax error") != NULL) {
    /* Provide more context for syntax errors */
    fprintf(stderr, "Error at line %d: Syntax error near '%s'\n", yylineno, yytext);
    
    /* Try to provide more specific guidance based on the current token */
    if (strcmp(yytext, "}") == 0) {
      fprintf(stderr, "  Hint: Check for missing semicolon or unbalanced braces\n");
    } else if (strcmp(yytext, ";") == 0) {
      fprintf(stderr, "  Hint: Check for invalid syntax before this semicolon\n");
    } else if (strcmp(yytext, "{") == 0) {
      fprintf(stderr, "  Hint: Check for missing identifier or keyword before this brace\n");
    } else {
      fprintf(stderr, "  Hint: Check syntax around this token\n");
    }
  } else {
    /* For other types of errors, just print the message with line number */
    fprintf(stderr, "Error at line %d: %s\n", yylineno, s);
  }
}

/* Form data structures */
typedef struct {
  char name[256];
  char type[256];
  int required;
  int has_min;
  int min_value;
  int has_max;
  int max_value;
  int has_default;
  int default_value;
  char default_text[256];
  char pattern[256];
  int has_pattern;
  int rows;
  int has_rows;
  int cols;
  int has_cols;
  char accept[256];
  int has_accept;
  char options[20][256];
  int option_count;
} Field;

typedef struct {
  char name[256];
  Field fields[50];
  int field_count;
} Section;

typedef struct {
  char name[256];
  Section sections[20];
  int section_count;
} Form;

Form form_data;
Section *current_section;
Field *current_field;

/* Semantic error checking functions */
int is_field_name_unique(char *field_name) {
  for (int i = 0; i < current_section->field_count; i++) {
    if (strcmp(current_section->fields[i].name, field_name) == 0) {
      return 0; /* Not unique */
    }
  }
  return 1; /* Unique */
}

int is_section_name_unique(char *section_name) {
  for (int i = 0; i < form_data.section_count; i++) {
    if (strcmp(form_data.sections[i].name, section_name) == 0) {
      return 0; /* Not unique */
    }
  }
  return 1; /* Unique */
}

int is_valid_field_type(char *type) {
  const char *valid_types[] = {
    "text", "email", "number", "date", "password", 
    "checkbox", "radio", "dropdown", "textarea", "file"
  };
  int num_types = sizeof(valid_types) / sizeof(valid_types[0]);
  
  for (int i = 0; i < num_types; i++) {
    if (strcmp(type, valid_types[i]) == 0) {
      return 1; /* Valid */
    }
  }
  return 0; /* Invalid */
}

void output_html();
%}

%union {
  int intval;
  int boolval;
  char *strval;
}

%token FORM META SECTION FIELD VALIDATE IF ERROR REQUIRED DEFAULT MIN MAX
%token PATTERN ROWS COLS ACCEPT
%token <strval> TYPE IDENTIFIER STRING_LITERAL
%token <intval> NUMBER
%token <boolval> BOOLEAN

%%

program: form;

form: 
  FORM IDENTIFIER '{' { strcpy(form_data.name, $2); form_data.section_count = 0; }
  form_body
  '}' { if (!has_errors) output_html(); };

form_body:
  /* empty */
  | form_body meta_statement
  | form_body section
  | form_body validate_block
  | form_body error ';' { 
      yyerror("Syntax error in form body - skipping to next statement");
      yyerrok; /* Reset error state */
  };

meta_statement: META IDENTIFIER '=' STRING_LITERAL ';';

section:
  SECTION IDENTIFIER '{' {
    if (!is_section_name_unique($2)) {
      char error_msg[256];
      sprintf(error_msg, "Section name '%s' is already used", $2);
      yyerror(error_msg);
    }
    current_section = &form_data.sections[form_data.section_count++];
    strcpy(current_section->name, $2);
    current_section->field_count = 0;
  }
  section_body
  '}';

section_body: 
  /* empty */ 
  | section_body field
  | section_body error ';' { 
      yyerror("Syntax error in section body - skipping to next field");
      yyerrok; /* Reset error state */
  };

field:
  FIELD IDENTIFIER ':' TYPE {
    if (!is_field_name_unique($2)) {
      char error_msg[256];
      sprintf(error_msg, "Field name '%s' is already used in this section", $2);
      yyerror(error_msg);
    }
    
    if (!is_valid_field_type($4)) {
      char error_msg[256];
      sprintf(error_msg, "Invalid field type '%s'", $4);
      yyerror(error_msg);
    }
    
    current_field = &current_section->fields[current_section->field_count++];
    strcpy(current_field->name, $2);
    strcpy(current_field->type, $4);
    current_field->required = 0;
    current_field->has_min = 0;
    current_field->has_max = 0;
    current_field->has_default = 0;
    current_field->has_pattern = 0;
    current_field->has_rows = 0;
    current_field->has_cols = 0;
    current_field->has_accept = 0;
    current_field->option_count = 0;
  }
  field_options
  ';';

field_options:
  /* empty */
  | field_options REQUIRED { current_field->required = 1; }
  | field_options MIN '=' NUMBER { current_field->has_min = 1; current_field->min_value = $4; }
  | field_options MAX '=' NUMBER { current_field->has_max = 1; current_field->max_value = $4; }
  | field_options DEFAULT '=' BOOLEAN { current_field->has_default = 1; current_field->default_value = $4; }
  | field_options DEFAULT '=' STRING_LITERAL { current_field->has_default = 1; strcpy(current_field->default_text, $4); }
  | field_options PATTERN '=' STRING_LITERAL { current_field->has_pattern = 1; strcpy(current_field->pattern, $4); }
  | field_options ROWS '=' NUMBER { current_field->has_rows = 1; current_field->rows = $4; }
  | field_options COLS '=' NUMBER { current_field->has_cols = 1; current_field->cols = $4; }
  | field_options ACCEPT '=' STRING_LITERAL { current_field->has_accept = 1; strcpy(current_field->accept, $4); }
  | field_options '[' option_list ']';

option_list:
  STRING_LITERAL { strcpy(current_field->options[current_field->option_count++], $1); }
  | option_list ',' STRING_LITERAL { strcpy(current_field->options[current_field->option_count++], $3); };

validate_block: VALIDATE '{' validate_statements '}';

validate_statements: 
  /* empty */ 
  | validate_statements validate_statement
  | validate_statements error '}' { 
      yyerror("Syntax error in validation rule - skipping to end of rule");
      yyerrok; /* Reset error state */
  };

validate_statement: IF condition '{' error_statement '}';
condition: IDENTIFIER '<' NUMBER;
error_statement: ERROR STRING_LITERAL ';';

%%

void output_html() {
  if (has_errors) {
    fprintf(stderr, "HTML generation skipped due to previous errors\n");
    return;
  }

  // Start HTML document
  fprintf(yyout, "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n");
  fprintf(yyout, "  <meta charset=\"UTF-8\">\n  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n");
  fprintf(yyout, "  <title>%s Form</title>\n", form_data.name);
  
  // Add CSS with black instead of blue for a more formal look
  fprintf(yyout, "  <style>\n");
  fprintf(yyout, "    body{font-family:sans-serif;line-height:1.6;color:#333;background:#f5f5f5}\n");
  fprintf(yyout, "    .container{max-width:800px;margin:2rem auto;padding:0 1rem}\n");
  fprintf(yyout, "    h1{color:#000;margin-bottom:1.5rem;text-align:center}\n");
  fprintf(yyout, "    form{background:white;border-radius:8px;padding:2rem;box-shadow:0 2px 5px rgba(0,0,0,.1)}\n");
  fprintf(yyout, "    .section{margin-bottom:2rem;padding-bottom:1rem;border-bottom:1px solid #ddd}\n");
  fprintf(yyout, "    h2{color:#000;font-size:1.5rem;margin-bottom:1rem;border-bottom:2px solid #000}\n");
  fprintf(yyout, "    .form-group{margin-bottom:1rem}\n");
  fprintf(yyout, "    label{display:block;margin-bottom:.5rem;font-weight:500}\n");
  fprintf(yyout, "    input,textarea,select{width:100%%;padding:.75rem;border:1px solid #ddd;border-radius:4px;font-size:1rem}\n");
  fprintf(yyout, "    button{background:#000;color:white;border:none;border-radius:4px;padding:.75rem 1.5rem;font-size:1rem;cursor:pointer}\n");
  fprintf(yyout, "    button:hover{background:#333}\n");
  fprintf(yyout, "    .submit-group{margin-top:2rem;text-align:center}\n");
  fprintf(yyout, "  </style>\n");
  fprintf(yyout, "</head>\n<body>\n  <div class=\"container\">\n");
  fprintf(yyout, "    <h1>%s</h1>\n    <form name=\"%s\">\n", form_data.name, form_data.name);
  
  // Output sections and fields
  for (int i = 0; i < form_data.section_count; i++) {
    Section *section = &form_data.sections[i];
    fprintf(yyout, "      <div class=\"section\">\n        <h2>%s</h2>\n", section->name);
    
    // Output fields in this section
    for (int j = 0; j < section->field_count; j++) {
      Field *field = &section->fields[j];
      
      if (strcmp(field->type, "radio") == 0) {
        fprintf(yyout, "        <div class=\"form-group\">\n          <label>%s:</label>\n", field->name);
        for (int k = 0; k < field->option_count; k++) {
          fprintf(yyout, "          <div><input type=\"radio\" id=\"%s_%s\" name=\"%s\" value=\"%s\"%s><label for=\"%s_%s\">%s</label></div>\n", 
                  field->name, field->options[k], field->name, field->options[k],
                  (field->required && k == 0) ? " required" : "",
                  field->name, field->options[k], field->options[k]);
        }
        fprintf(yyout, "        </div>\n");
      } else if (strcmp(field->type, "checkbox") == 0) {
        fprintf(yyout, "        <div class=\"form-group\">\n          <div><input type=\"checkbox\" id=\"%s\" name=\"%s\"%s><label for=\"%s\">%s</label></div>\n        </div>\n", 
                field->name, field->name, 
                (field->has_default && field->default_value) ? " checked" : "",
                field->name, field->name);
      } else if (strcmp(field->type, "dropdown") == 0) {
        fprintf(yyout, "        <div class=\"form-group\">\n          <label for=\"%s\">%s:</label>\n          <select id=\"%s\" name=\"%s\"%s>\n", 
                field->name, field->name, field->name, field->name,
                field->required ? " required" : "");
        fprintf(yyout, "            <option value=\"\">-- Select %s --</option>\n", field->name);
        for (int k = 0; k < field->option_count; k++) {
          fprintf(yyout, "            <option value=\"%s\"%s>%s</option>\n", 
                  field->options[k],
                  (field->has_default && strcmp(field->default_text, field->options[k]) == 0) ? " selected" : "",
                  field->options[k]);
        }
        fprintf(yyout, "          </select>\n        </div>\n");
      } else if (strcmp(field->type, "textarea") == 0) {
        fprintf(yyout, "        <div class=\"form-group\">\n          <label for=\"%s\">%s:</label>\n", field->name, field->name);
        fprintf(yyout, "          <textarea id=\"%s\" name=\"%s\"", field->name, field->name);
        
        if (field->has_rows) {
          fprintf(yyout, " rows=\"%d\"", field->rows);
        }
        
        if (field->has_cols) {
          fprintf(yyout, " cols=\"%d\"", field->cols);
        }
        
        if (field->required) {
          fprintf(yyout, " required");
        }
        
        fprintf(yyout, ">");
        
        if (field->has_default) {
          fprintf(yyout, "%s", field->default_text);
        }
        
        fprintf(yyout, "</textarea>\n        </div>\n");
      } else if (strcmp(field->type, "file") == 0) {
        fprintf(yyout, "        <div class=\"form-group\">\n          <label for=\"%s\">%s:</label>\n", field->name, field->name);
        fprintf(yyout, "          <input type=\"file\" id=\"%s\" name=\"%s\"", field->name, field->name);
        
        if (field->has_accept) {
          fprintf(yyout, " accept=\"%s\"", field->accept);
        }
        
        if (field->required) {
          fprintf(yyout, " required");
        }
        
        fprintf(yyout, ">\n        </div>\n");
      } else {
        // Handle text, email, number, date, password
        fprintf(yyout, "        <div class=\"form-group\">\n          <label for=\"%s\">%s:</label>\n", field->name, field->name);
        fprintf(yyout, "          <input type=\"%s\" id=\"%s\" name=\"%s\"", field->type, field->name, field->name);
        
        if (field->has_min) {
          fprintf(yyout, " min=\"%d\"", field->min_value);
        }
        
        if (field->has_max) {
          fprintf(yyout, " max=\"%d\"", field->max_value);
        }
        
        if (field->has_pattern) {
          fprintf(yyout, " pattern=\"%s\"", field->pattern);
        }
        
        if (field->has_default && (strcmp(field->type, "text") == 0 || 
                                  strcmp(field->type, "email") == 0 || 
                                  strcmp(field->type, "password") == 0)) {
          fprintf(yyout, " value=\"%s\"", field->default_text);
        }
        
        if (field->required) {
          fprintf(yyout, " required");
        }
        
        fprintf(yyout, ">\n        </div>\n");
      }
    }
    fprintf(yyout, "      </div>\n");
  }
  
  // Add submit button and close form
  fprintf(yyout, "      <div class=\"form-group submit-group\">\n        <button type=\"submit\">Submit</button>\n      </div>\n");
  fprintf(yyout, "    </form>\n  </div>\n</body>\n</html>\n");
}

int main(int argc, char **argv) {
  if (argc > 1) {
    yyin = fopen(argv[1], "r");
    if (!yyin) {
      printf("Cannot open input file: %s\n", argv[1]);
      return 1;
    }
  } else {
    yyin = stdin;
  }
  
  if (argc > 2) {
    yyout = fopen(argv[2], "w");
    if (!yyout) {
      printf("Cannot open output file: %s\n", argv[2]);
      return 1;
    }
  } else {
    yyout = stdout;
  }
  
  yyparse();
  
  if (yyin != stdin) fclose(yyin);
  if (yyout != stdout) fclose(yyout);
  
  return has_errors ? 1 : 0;
}