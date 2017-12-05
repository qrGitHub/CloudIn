#include <iostream>
#include <string>
using namespace std;

static constexpr uint32_t MATCH_CASE_INSENSITIVE = 0x01;

static bool char_eq(char c1, char c2)
{
  return c1 == c2;
}

static bool ci_char_eq(char c1, char c2)
{
  return tolower(c1) == tolower(c2);
}

static bool match_wildcards(const char *, const char *, uint32_t);
static bool match_asterisk(const char *pattern, const char *input, uint32_t flags) {
  while ('\0' != *input) {
    if (match_wildcards(pattern, input, flags)) 
      return true;
    input++;
  }

  return '\0' == *pattern;
}

static bool match_wildcards(const char *pattern, const char *input, uint32_t flags) {
  const auto eq = (flags & MATCH_CASE_INSENSITIVE) ? &ci_char_eq : &char_eq;

  while (true) {
    if ('\0' == *pattern)
      return '\0' == *input;

    if ('*' == *pattern)
      return match_asterisk(pattern+1, input, flags);

    if ('\0' == *input)
      return false;

    if ('?' == *pattern || eq(*pattern, *input)) {
      pattern++;
      input++;
      continue;
    }

    return false;
  }
}

bool match_wildcards(string pattern, string input, uint32_t flags)
{
  const char *p_input = input.c_str();
  const char *p_pattern = pattern.c_str();
  return match_wildcards(p_pattern, p_input, flags);
}

int main() {
  string pattern = "ab*", input = "ABCCC";
  cout << match_wildcards("*", "", 0) << endl;
  cout << match_wildcards("*", "43", 0) << endl;
  cout << match_wildcards("*3", "3", 0) << endl;
  cout << match_wildcards("*3", "4", 0) << endl;
  cout << match_wildcards("3*", "", 0) << endl;
  cout << match_wildcards("3*", "31237", 0) << endl;
  cout << match_wildcards("3*7*8", "312378", 0) << endl;
  cout << match_wildcards(pattern, input, 1) << endl;
}
