#include <iostream>
#include <set>
#include <string>
#include <vector>
#include <map>
#include "lang.hh"

using namespace std;

class VariableCheckVisitor : public ExprVisitor {
  map<string, int> assignments;
  vector<pair<string, int>> errors;
  public:
    vector<string> visit(IntegerExpr int_expr) override {
      return vector<string> {};
    }

    void visit(Program program) {
      for (auto line : program.get_lines()) {
        string id = line->identifier;
        if (assignments.find(id) == assignments.end()) {
          assignments[id] = line->line_number;
        }
      }

      for (auto line : program.get_lines()) {
        int line_number = line->line_number;
        vector<string> used_variables;
        if (line->expression->type == ExprType::Variable) {
          VarExpr* expr = static_cast<VarExpr*>(line->expression);
        }
        else if (line->expression->type == ExprType::Function) {
          FunctionExpr* expr = static_cast<FunctionExpr*>(line->expression);
            used_variables = expr->accept(*this);
        }

        for (auto var : used_variables) {
          if (assignments[var] >= line_number) {
            errors.push_back(make_pair(var, line_number));
          }
        }
      }

      for (auto p : errors) {
        cout << "variable " << p.first << " is used before initializing in line" << p.second << endl;
      }
    }

    vector<string> visit(VarExpr var_expr) override {
      return vector<string> { var_expr.identifier };
    }

    vector<string> visit(FunctionExpr func_expr) override {
      vector<string> used_variables;
      for (auto arg : func_expr.get_args()) {
        if (arg->type == ExprType::Variable) {
          VarExpr* expr = static_cast<VarExpr*>(arg);
          used_variables.push_back(expr->accept(*this)[0]);
        }
        else if (arg->type == ExprType::Function) {
          FunctionExpr* expr = static_cast<FunctionExpr*>(arg);
          auto result = arg->accept(*this);
          used_variables.insert(used_variables.end(), result.begin(), result.end());
        }
      }
      return used_variables;
    }
};

class LineCheckVisitor : public ProgramVisitor {
  set<int> lines;
  set<int> errors;
  public:
    bool visit (Program program) override {
      for (auto line : program.get_lines()) {
        int line_number = line->line_number;

        if (lines.find(line_number) != lines.end()) {
          if (errors.find(line_number) == errors.end()) {
            errors.insert(line_number);
          }
        } else {
          lines.insert(line_number);
        }
      }

      bool success = true;
      for (int error_line : errors) {
        cout << "program contains duplicate lines with number " << error_line << endl;
        success = false;
      }

      return success;
    }
};

int main() {
  Program* program;
  int result = yyparse(&program);
  auto line_check_visitor = LineCheckVisitor();
  bool success = program->accept(line_check_visitor);

  if (success) {
    auto var_visitor = VariableCheckVisitor();
    program->accept(var_visitor);
  }
  return 0;
}
