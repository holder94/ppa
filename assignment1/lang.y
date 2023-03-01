%code requires {
  #include <iostream>
  #include <string>
  #include <vector>

  using namespace std;


  class Program;
  class IntegerExpr;
  class VarExpr;
  class FunctionExpr;

  class ProgramVisitor {
    public:
      virtual bool visit(Program program) = 0;
      virtual ~ProgramVisitor() {}
  };

  class ExprVisitor {
    public:
      virtual vector<string> visit(IntegerExpr int_expr) = 0;
      virtual vector<string> visit(VarExpr var_expr) = 0;
      virtual vector<string> visit(FunctionExpr func_expr) = 0;
      virtual void visit(Program program) = 0;
      virtual ~ExprVisitor() {}
  };

  enum ExprType { Variable, Integer, Function };

  class Expr {
    protected:
      Expr(ExprType expr_type): type(expr_type) {}
    public:
      ExprType type;
      virtual vector<string> accept(ExprVisitor& visitor) = 0;
      virtual ~Expr() {}
  };

  class IntegerExpr : public Expr {
    public:
      int value;
      IntegerExpr(int integer) : value(integer), Expr(ExprType::Integer) {}
      vector<string> accept(ExprVisitor& visitor) override {
        return visitor.visit(*this);
      }
  };

  class FunctionExpr : public Expr {
    vector<Expr*> args;
    public:
      FunctionExpr(vector<Expr*> arguments) : args(arguments), Expr(ExprType::Function) {}
      vector<Expr*> get_args() {
        return args;
      }
      vector<string> accept(ExprVisitor& visitor) override {
        return visitor.visit(*this);
      }
  };

  class VarExpr : public Expr {
    Expr* value;
    public:
      const char* identifier;
      VarExpr(const char* var_name) : identifier(var_name), Expr(ExprType::Variable) {}
      vector<string> accept(ExprVisitor& visitor) override {
        return visitor.visit(*this);
      }
  };

  class Line {
    public:
      Expr* expression;
      Line(int line, const char* id, Expr* expr) : line_number(line), identifier(id), expression(expr) {}
      const char* identifier;
      int line_number;
  };

  class Program {
    vector<Line*> lines;
    public:
      Program(vector<Line*> program_lines) : lines(program_lines) {}
      vector<Line*> get_lines() {
        return this->lines;
      }
      bool accept(ProgramVisitor& visitor) {
        return visitor.visit(*this);
      }

      void accept(ExprVisitor &visitor) {
        visitor.visit(*this);
      }

  };

  extern int yylineno;
  extern int yylex(void);
  extern int yyerror(Program**, const char*);

  typedef struct {
    int integer;
    char* str;
    Expr* expr;
    vector<Expr*> exprs;
    Line* line_type;
    vector<Line*> lines_type;
    Program* program;
  } YYSTYPE;
  #define YYSTYPE YYSTYPE
}

%parse-param { Program** result }

%token EOL ASSIGNMENT_OP LPAREN RPAREN COMMA FUNC
// number is non-negative
%token <integer> INTEGER NUMBER
%token <str> WORD

%type <expr> expression
%type <exprs> expressions
%type <line_type> line
%type <lines_type> lines
%type <program> start

%%

start:
  lines { *result = new Program($1); }
;

lines:
  line EOL lines {
    vector<Line*> result = { $1 };
    vector<Line*> other_lines = $3;
    result.insert(result.end(), other_lines.begin(), other_lines.end());
    $$ = result;
  }
| line { $$ = vector<Line*> { $1 }; }
;

line:
  NUMBER WORD ASSIGNMENT_OP expression {
    $$ = new Line($1, $2, $4);
  }
;

expression:
  WORD { $$ = new VarExpr($1); }
| INTEGER { $$ = new IntegerExpr($1); }
| NUMBER  { $$ = new IntegerExpr($1); }
| FUNC LPAREN expressions RPAREN {
    $$ = new FunctionExpr($3);
  }
;

expressions:
  expression COMMA expressions {
    vector<Expr*> result = { $1 };
    vector<Expr*> other_exprs = $3;
    result.insert(result.end(), other_exprs.begin(), other_exprs.end());
    $$ = result;
  }
| expression { $$ = vector<Expr*> { $1 }; }
;

%%

int yyerror(Program** program, const char* msg) {
  fprintf(stderr, "error: %s on line %d\n", msg, yylineno);
  return 1;
}
