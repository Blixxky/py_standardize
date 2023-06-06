## Python Formatting and Linting Script

This PowerShell script automates the task of running several Python code formatting and linting tools on all Python files in the current directory and its subdirectories (excluding 'MFB' directory). The output of these tools is written to report_log_trimmed.txt after junk is removed. The script installs and uses the following Python libraries:

1. **Black**: This is an uncompromising Python code formatter. It takes care of all the stylistic decisions of your code so you can focus on the logic. It helps maintain a consistent style in your project and makes it easier for others to read and understand your code.

2. **Flake8**: Flake8 is a powerful tool that checks your Python code against some of the style conventions in PEP 8. It also includes PyFlakes, a tool for detecting various errors in Python code, and McCabe, a tool for measuring code complexity.

3. **MyPy**: This is a static type checker for Python. It combines the benefits of dynamic typing and static typing. As you write your code, MyPy ensures that it adheres to the type annotations you've set, catching common errors before runtime.

4. **Pylint**: Pylint is a highly configurable tool for performing static analysis of Python code. It checks for programming errors, helps enforce a coding standard, sniffs for code smells, and offers simple refactoring suggestions.

5. **Autoflake**: Autoflake removes unused imports and unused variables from Python code. It makes your code cleaner and helps reduce clutter. 

This combination of tools ensures that your Python code is well-formatted, follows Python's recommended style guide (PEP 8), is free from common programming errors, and is not cluttered with unused imports or variables. 

The script runs each of these libraries on every Python file, and collects the outputs in a text file. After all files have been processed, the script trims unnecessary output lines from the final report.

## PY version coming shortly.
