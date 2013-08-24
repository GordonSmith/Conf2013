EXPORT StrAlgorithms := MODULE, FORWARD
  IMPORT Std;
  EXPORT Bundle := MODULE(Std.BundleBase)
    EXPORT Name := 'CellFormatter';
    EXPORT Description := 'Distance Algorithms';
    EXPORT Authors := ['Gordon Smith'];
    EXPORT License := 'http://www.apache.org/licenses/LICENSE-2.0';
    EXPORT Copyright := 'Copyright (C) 2013 HPCC Systems';
    EXPORT DependsOn := [];
    EXPORT Version := '1.0.0';
  END;
  
  EXPORT Levenshtein(STRING Str1, STRING Str2) := MODULE
	INTEGER4 LevenshteinCPP(STRING s1, STRING s2) := BEGINC++
#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))
#body
unsigned int x, y, lastdiag, olddiag;
unsigned int* column = new unsigned int[lenS1+1];
for (y = 1; y <= lenS1; y++)
    column[y] = y;
for (x = 1; x <= lenS2; x++) {
    column[0] = x;
    for (y = 1, lastdiag = x-1; y <= lenS1; y++) {
        olddiag = column[y];
        column[y] = MIN3(column[y] + 1, column[y-1] + 1, lastdiag + (s1[y-1] == s2[x-1] ? 0 : 1));
        lastdiag = olddiag;
    }
}
int retVal = column[lenS1];
delete[] column;
return(retVal);	
	ENDC++;
	EXPORT Result := LevenshteinCPP(Str1, Str2);
  END;
  
  EXPORT LongestCommonSubsequence(STRING Str1, STRING Str2) := MODULE
	STRING LongestCommonSubsequenceCPP(STRING s1, STRING s2) := BEGINC++
#include <algorithm>
#include <string>
#include <vector>
 
#include <stdio.h>
#include <string.h>
 
class LCS
{
    class LCSTable
    {
        size_t   m_;
        size_t   n_;
        size_t*  data_;
    public:
        LCSTable(size_t m, size_t n)
        : m_(m)
        , n_(n)
        {
            data_ = new size_t[(m_ + 1) * (n_ + 1)];
        }
        ~LCSTable()
        {
            delete [] data_;
        }
 
        void setAt(size_t i, size_t j, size_t value)
        {
            data_[i + j * (m_ + 1)] = value;
        }
 
        size_t getAt(size_t i, size_t j) const
        {
            return data_[i + j * (m_ + 1)];
        }
 
        template<typename T> void
        build(const T* X, const T* Y)
        {
            for (size_t i=0; i<=m_; ++i)
                setAt(i, 0, 0);
 
            for (size_t j=0; j<=n_; ++j)
                setAt(0, j, 0);
 
            for (size_t i = 0; i < m_; ++i)
            {
                for (size_t j = 0; j < n_; ++j)
                {
                    if (X[i] == Y[j])
                        setAt(i+1, j+1, getAt(i, j)+1);
                    else
                        setAt(i+1, j+1, std::max(getAt(i+1, j), getAt(i, j+1)));
                }
            }
        }
    };
 
    template<typename T> static void
    backtrackOne(const LCSTable& table,
                 const T* X, const T* Y, size_t i, size_t j,
                 std::vector<T>& result)
    {
        if (i == 0 || j == 0)
            return;
        if (X[i - 1] == Y[j - 1])
        {
            backtrackOne(table, X, Y, i - 1, j - 1, result);
            result.push_back(X[i - 1]);
            return;
        }
        if (table.getAt(i, j - 1) > table.getAt(i -1, j))
            backtrackOne(table, X, Y, i, j - 1, result);
        else
            backtrackOne(table, X, Y, i - 1, j, result);
    }
 
public:
    template<typename T> static void
    findOne(const T* X, size_t m, const T* Y, size_t n,
            std::vector<T>& result)
    {
        LCSTable table(m, n);
        table.build(X, Y);
        backtrackOne(table, X, Y, m, n, result);
    }
};  
#body
std::vector<char> result;
LCS::findOne<char>(s1, lenS1, s2, lenS2, result);
__lenResult = result.size();
__result = (char *)rtlMalloc(__lenResult);
strncpy(__result, &result[0], __lenResult); 
	  ENDC++;
	EXPORT Result := LongestCommonSubsequenceCPP(Str1, Str2);
  END;
  
  EXPORT LongestCommonSubstring(STRING Str1, STRING Str2) := MODULE
	INTEGER4 LongestCommonSubstringCPP(STRING s1, STRING s2) := BEGINC++
#include <string>
using std::string;
#body 
 if(lenS1 == 0 || lenS2 == 0)
      return 0;
      
 //string str1 = s1;          
 //string str2 = s2;          
 
int *curr = new int [lenS2];
int *prev = new int [lenS2];
int *swap = NULL;
int maxSubstr = 0;
for(int i = 0; i<lenS1; ++i)
{
     for(int j = 0; j<lenS1; ++j)
     {
          if((*s1)[i] != (*s2)[j])
          {
               curr[j] = 0;
          }
          else
          {
               if(i == 0 || j == 0)
               {
                    curr[j] = 1;
               }
               else
               {
                    curr[j] = 1 + prev[j-1];
              }
               //The next if can be replaced with:
               //maxSubstr = max(maxSubstr, curr[j]);
               //(You need algorithm.h library for using max())
               if(maxSubstr < curr[j])
               {
                    maxSubstr = curr[j];
               }
          }
     }
     swap=curr;
     curr=prev;
     prev=swap;
}
delete [] curr;
delete [] prev;
return maxSubstr;
      ENDC++;
    EXPORT Result := LongestCommonSubstringCPP(Str1, Str2);
  END;
END;
 
  /*
function levenshteinDistance(s, t) {
  // Determine the Levenshtein distance between s and t
  if (!s || !t) {
    return 99;
  }
  var m = s.length;
  var n = t.length;
  
//   For all i and j, d[i][j] holds the Levenshtein distance between
//   * the first i characters of s and the first j characters of t.
//   * Note that the array has (m+1)x(n+1) values.
//   
  var d = new Array();
  for (var i = 0; i <= m; i++) {
    d[i] = new Array();
    d[i][0] = i;
  }
  for (var j = 0; j <= n; j++) {
    d[0][j] = j;
  }
              
  // Determine substring distances
  var cost = 0;
  for (var j = 1; j <= n; j++) {
    for (var i = 1; i <= m; i++) {
      cost = (s.charAt(i-1) == t.charAt(j-1)) ? 0 : 1;  // Subtract one to start at strings' index zero instead of index one
      d[i][j] = Math.min(d[i][j-1] + 1,                 // insertion
                         Math.min(d[i-1][j] + 1,        // deletion
                                  d[i-1][j-1] + cost)); // substitution                              
    }
  }
  
  // Return the strings' distance
  return d[m][n];
}
*/


/*
'Optimal' String-Alignment Distance

This is a variation of the Damerau-Levenshtein distance that returns the strings' edit distance taking into account deletion, insertion, substitution, and transposition, under the condition that no substring is edited more than once.

For example, optimalStringAlignmentDistance('ca', 'abc') == 3 because if the transposition 'ca' -> 'ac' is used, it is not possible to use the insertion 'ac' -> 'abc'. The shortest sequence of operations is 'ca' -> 'a' -> 'ab' -> 'abc'.

Contributed by hpshelton.

function optimalStringAlignmentDistance(s, t) {
  // Determine the "optimal" string-alignment distance between s and t
  if (!s || !t) {
    return 99;
  }
  var m = s.length;
  var n = t.length;
  
//   For all i and j, d[i][j] holds the string-alignment distance
//   * between the first i characters of s and the first j characters of t.
//   * Note that the array has (m+1)x(n+1) values.
//   
  var d = new Array();
  for (var i = 0; i <= m; i++) {
    d[i] = new Array();
    d[i][0] = i;
  }
  for (var j = 0; j <= n; j++) {
    d[0][j] = j;
  }
        
  // Determine substring distances
  var cost = 0;
  for (var j = 1; j <= n; j++) {
    for (var i = 1; i <= m; i++) {
      cost = (s.charAt(i-1) == t.charAt(j-1)) ? 0 : 1;   // Subtract one to start at strings' index zero instead of index one
      d[i][j] = Math.min(d[i][j-1] + 1,                  // insertion
                         Math.min(d[i-1][j] + 1,         // deletion
                                  d[i-1][j-1] + cost));  // substitution
                        
      if(i > 1 && j > 1 && s.charAt(i-1) == t.charAt(j-2) && s.charAt(i-2) == t.charAt(j-1)) {
        d[i][j] = Math.min(d[i][j], d[i-2][j-2] + cost); // transposition
      }
    }
  }
  
  // Return the strings' distance
  return d[m][n];
}
Damerau-Levenshtein Distance

Returns the strings' edit distance taking into account deletion, insertion, substitution, and transposition, without the condition imposed by the 'optimal' string alignment distance algorithm above.

For example, damerauLevenshteinDistance('ca', 'abc') == 2 because 'ca' -> 'ac' -> 'abc'.

Contributed by hpshelton.

function damerauLevenshteinDistance(s, t) {
  // Determine the Damerau-Levenshtein distance between s and t
  if (!s || !t) {
    return 99;
  }
  var m = s.length;
  var n = t.length;      
  var charDictionary = new Object();
  
//   For all i and j, d[i][j] holds the Damerau-Levenshtein distance
//   * between the first i characters of s and the first j characters of t.
//   * Note that the array has (m+1)x(n+1) values.
//   
  var d = new Array();
  for (var i = 0; i <= m; i++) {
    d[i] = new Array();
    d[i][0] = i;
  }
  for (var j = 0; j <= n; j++) {
    d[0][j] = j;
  }
  
  // Populate a dictionary with the alphabet of the two strings
  for (var i = 0; i < m; i++) {
    charDictionary[s.charAt(i)] = 0;
  }
  for (var j = 0; j < n; j++) {
    charDictionary[t.charAt(j)] = 0;
  }
  
  // Determine substring distances
  for (var i = 1; i <= m; i++) {
    var db = 0;
    for (var j = 1; j <= n; j++) {
      var i1 = charDictionary[t.charAt(j-1)];
      var j1 = db;
      var cost = 0;
      
      if (s.charAt(i-1) == t.charAt(j-1)) { // Subtract one to start at strings' index zero instead of index one
        db = j;
      } else {
        cost = 1;
      }
      d[i][j] = Math.min(d[i][j-1] + 1,                 // insertion
                         Math.min(d[i-1][j] + 1,        // deletion
                                  d[i-1][j-1] + cost)); // substitution
      if(i1 > 0 && j1 > 0) {
        d[i][j] = Math.min(d[i][j], d[i1-1][j1-1] + (i-i1-1) + (j-j1-1) + 1); //transposition
      }
    }
    charDictionary[s.charAt(i-1)] = i;
  }
        
  // Return the strings' distance
  return d[m][n];
}  
*/
