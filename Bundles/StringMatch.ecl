EXPORT StringMatch := MODULE, FORWARD
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
	
	EXPORT Distance := MODULE
		EXPORT Hamming(STRING Str1, STRING Str2) := MODULE
			UNSIGNED INTEGER4 HammingCPP(STRING s1, STRING s2) := BEGINC++
			#option pure
				#include <algorithm>
			#body
				if(lenS1 == 0 && lenS2 == 0) {
					return 0;
				} else if (lenS1 == 0) {
					return lenS2;
				} else if (lenS2 == 0) {
					return lenS1;
				}
				
				unsigned int dist = (int)abs((int)(lenS1 - lenS2));
				unsigned int len = std::min(lenS1, lenS2);
				for (unsigned int i = 0; i < len; ++i) {
					if (s1[i] != s2[i]) {
						++dist;
					}
				}
				return dist;
			ENDC++;
	
			EXPORT Result := HammingCPP(Str1, Str2);
		END;
	  
		EXPORT Levenshtein(STRING Str1, STRING Str2) := MODULE
			UNSIGNED INTEGER4 LevenshteinCPP(STRING s1, STRING s2) := BEGINC++
			#option pure
				#define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))
			#body
				if(lenS1 == 0 && lenS2 == 0) {
					return 0;
				} else if (lenS1 == 0) {
					return lenS2;
				} else if (lenS2 == 0) {
					return lenS1;
				}
	
				unsigned int* column = new unsigned int[lenS1 + 1];
				for (int y = 1; y <= lenS1; y++)
				    column[y] = y;
			
				unsigned int lastdiag, olddiag;
				for (int x = 1; x <= lenS2; x++) {
				    column[0] = x;
				    for (int y = 1, lastdiag = x-1; y <= lenS1; y++) {
				        olddiag = column[y];
				        column[y] = MIN3(column[y] + 1, column[y - 1] + 1, lastdiag + (s1[y - 1] == s2[x - 1] ? 0 : 1));
				        lastdiag = olddiag;
				    }
				}
			
				int retVal = column[lenS1];
				delete[] column;
				return(retVal);	
			ENDC++;
	
			EXPORT Result := LevenshteinCPP(Str1, Str2);
		END;
	  
		EXPORT OptimalStringAlignment(STRING Str1, STRING Str2) := MODULE
			UNSIGNED INTEGER4 OptimalStringAlignmentCPP(STRING s1, STRING s2) := BEGINC++
			#option pure
				#include <vector>
				namespace OSAD {
					typedef std::vector<unsigned int> uiVector;
					typedef std::vector<uiVector> uiVectorVector;
				}
			#body
				if(lenS1 == 0 && lenS2 == 0) {
					return 0;
				} else if (lenS1 == 0) {
					return lenS2;
				} else if (lenS2 == 0) {
					return lenS1;
				}
	
				OSAD::uiVectorVector d(lenS1 + 1);   
				for (unsigned int i = 0; i <= lenS1; ++i) {
				    d[i].resize(lenS2 + 1);
				    d[i][0] = i;
				}
				for (unsigned int j = 0; j <= lenS2; ++j) {
				    d[0][j] = j;
				}
	
				unsigned int cost = 0;
				for (unsigned int j = 1; j <= lenS2; j++) {
					for (unsigned int i = 1; i <= lenS1; i++) {
						cost = (s1[i-1] == s2[j-1]) ? 0 : 1;
						d[i][j] = std::min(d[i][j-1] + 1, std::min(d[i-1][j] + 1, d[i-1][j-1] + cost));
						if(i > 1 && j > 1 && s1[i-1] == s2[j-2] && s1[i-2] == s2[j-1]) {
							d[i][j] = std::min(d[i][j], d[i-2][j-2] + cost);
						}
					}
				}
				return d[lenS1][lenS2];
			ENDC++;
	
			EXPORT Result := OptimalStringAlignmentCPP(Str1, Str2);
		END;
		
		EXPORT DamerauLevenshtein(STRING Str1, STRING Str2) := MODULE
			UNSIGNED INTEGER4 DamerauLevenshteinCPP(STRING s1, STRING s2) := BEGINC++
			#option pure
				#include <vector>
				#include <map>
				namespace DLD {
					typedef std::map<char, int> ciMap;
					typedef std::vector<unsigned int> uiVector;
					typedef std::vector<uiVector> uiVectorVector;
				}
			#body
				if(lenS1 == 0 && lenS2 == 0) {
					return 0;
				} else if (lenS1 == 0) {
					return lenS2;
				} else if (lenS2 == 0) {
					return lenS1;
				}
				DLD::ciMap charDictionary;
				DLD::uiVectorVector d(lenS1 + 1);
				for (unsigned int i = 0; i <= lenS1; i++) {
					d[i].resize(lenS2 + 1);
					d[i][0] = i;
				}
				for (unsigned int j = 0; j <= lenS2; j++) {
					d[0][j] = j;
				}
				for (unsigned int i = 0; i < lenS1; i++) {
					charDictionary[s1[i]] = 0;
				}
				for (unsigned int j = 0; j < lenS2; j++) {
					charDictionary[s2[j]] = 0;
				}
				for (unsigned int i = 1; i <= lenS1; i++) {
					unsigned int db = 0;
					for (unsigned int j = 1; j <= lenS2; j++) {
						unsigned int i1 = charDictionary[s2[j-1]];
						unsigned int j1 = db;
						unsigned int cost = 0;
						if (s1[i-1] == s2[j-1]) {
							db = j;
						} else {
							cost = 1;
						}
						d[i][j] = std::min(d[i][j-1] + 1, std::min(d[i-1][j] + 1, d[i-1][j-1] + cost));
						if(i1 > 0 && j1 > 0) {
							d[i][j] = std::min(d[i][j], d[i1-1][j1-1] + (i-i1-1) + (j-j1-1) + 1);
						}
					}
					charDictionary[s1[i-1]] = i;
				}
				return d[lenS1][lenS2];
			ENDC++;
	
			EXPORT Result := DamerauLevenshteinCPP(Str1, Str2);
		END;
		
		EXPORT Sift3B(STRING Str1, STRING Str2) := MODULE
			REAL4 Sift3BCPP(STRING s1, STRING s2) := BEGINC++
			#option pure
				namespace S3B {
					float roundf(float value) {
					  return floor(value + 0.5);
					}
				}
			#body
				if(lenS1 == 0 && lenS2 == 0) {
					return 0;
				} else if (lenS1 == 0) {
					return lenS2;
				} else if (lenS2 == 0) {
					return lenS1;
				}
				unsigned int c1 = 0;
				unsigned int c2 = 0;
				unsigned int lcs = 0;
				unsigned int temporaryDistance = 0;
				unsigned int maxOffset = 5;
	
			    while ((c1 < lenS1) && (c2 < lenS2)) {
			        if (s1[c1] == s2[c2]) {
			            lcs++;
			        } else {
			            if (c1<c2) {
			                c2=c1;
			            } else {
			                c1=c2;
			            }
			            for (unsigned int i = 0; i < maxOffset; i++) {
			                if ((c1 + i < lenS1) && (s1[c1 + i] == s2[c2])) {
			                    c1+= i;
			                    break;
			                }
			                if ((c2 + i < lenS2) && (s1[c1] == s2[c2 + i])) {
			                    c2+= i;
			                    break;
			                }
			            }
			        }
			        c1++;
			        c2++;
			    }
				return S3B::roundf((lenS1 + lenS2) / 1.5 - lcs);
			ENDC++;
	
			EXPORT Result := Sift3BCPP(Str1, Str2);
		END;
	END;

	EXPORT LongestCommonSubsequence(STRING Str1, STRING Str2) := MODULE
		STRING LongestCommonSubsequenceCPP(STRING s1, STRING s2) := BEGINC++
		#option pure
			#include <vector>
			 
			class LCS {
			    class LCSTable {
			        size_t   m_;
			        size_t   n_;
			        size_t*  data_;
			        
			    public:
			        LCSTable(size_t m, size_t n) : m_(m), n_(n) {
			            data_ = new size_t[(m_ + 1) * (n_ + 1)];
			        }
			        ~LCSTable() {
			            delete [] data_;
			        }
			 
			        void setAt(size_t i, size_t j, size_t value) {
			            data_[i + j * (m_ + 1)] = value;
			        }
			 
			        size_t getAt(size_t i, size_t j) const {
			            return data_[i + j * (m_ + 1)];
			        }
			 
			        template<typename T> void build(const T* X, const T* Y) {
			            for (size_t i=0; i<=m_; ++i)
			                setAt(i, 0, 0);
			 
			            for (size_t j=0; j<=n_; ++j)
			                setAt(0, j, 0);
			 
			            for (size_t i = 0; i < m_; ++i) {
			                for (size_t j = 0; j < n_; ++j) {
			                    if (X[i] == Y[j])
			                        setAt(i+1, j+1, getAt(i, j)+1);
			                    else
			                        setAt(i+1, j+1, std::max(getAt(i+1, j), getAt(i, j+1)));
			                }
			            }
			        }
			    };
			 
			    template<typename T> static void backtrackOne(const LCSTable& table, const T* X, const T* Y, size_t i, size_t j, std::vector<T>& result) {
			        if (i == 0 || j == 0)
			            return;
			        if (X[i - 1] == Y[j - 1]) {
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
			    template<typename T> static void findOne(const T* X, size_t m, const T* Y, size_t n, std::vector<T>& result) {
			        LCSTable table(m, n);
			        table.build(X, Y);
			        backtrackOne(table, X, Y, m, n, result);
			    }
			};  
		#body
			if(lenS1 == 0 || lenS2 == 0) {
				__lenResult = 0;
				__result = NULL;
				return;
			}
			std::vector<char> result;
			LCS::findOne<char>(s1, lenS1, s2, lenS2, result);
			__lenResult = result.size();
			__result = (char *)rtlMalloc(__lenResult);
			strncpy(__result, &result[0], __lenResult); 
		ENDC++;
		EXPORT Result := LongestCommonSubsequenceCPP(Str1, Str2);
	END;
  
	EXPORT LongestCommonSubstring(STRING Str1, STRING Str2) := MODULE
		SET OF UNSIGNED INTEGER4 LongestCommonSubstringCPP(STRING s1, STRING s2) := BEGINC++
			if(lenS1 == 0 || lenS2 == 0) {
				__isAllResult = false;
				__lenResult = 0;
				__result = NULL;
				return;
			}

			int *curr = new int [lenS2];
			int *prev = new int [lenS2];
			int *swap = NULL;
			int maxSubstr = 0;
			int lastSubsBegin = 0;
			for(int i = 0; i < lenS1; ++i) {
			     for(int j = 0; j < lenS2; ++j) {
			          if(s1[i] != s2[j]) {
			               curr[j] = 0;
			          } else {
			               if(i == 0 || j == 0) {
			                    curr[j] = 1;

			               } else {
			                    curr[j] = 1 + prev[j-1];
			              }
			               if(maxSubstr < curr[j]) {
			                    maxSubstr = curr[j];
								int thisSubsBegin = i - curr[j] + 1;
			                    if (lastSubsBegin != thisSubsBegin) {
			                    	lastSubsBegin = thisSubsBegin;
			                    }                    
			               }
			          }
			     }
			     swap=curr;
			     curr=prev;
			     prev=swap;
			}

			delete [] curr;
			delete [] prev;
			__isAllResult = false;
			__lenResult = 2 * sizeof(size32_t);
			__result = rtlMalloc(__lenResult);
			size32_t * cur = (size32_t *)__result;
			*cur = maxSubstr;
			*(++cur) = lastSubsBegin;
		ENDC++;
		SHARED Result := LongestCommonSubstringCPP(Str1, Str2);
	    EXPORT MaxLen := Result[1];
	    StartPos := Result[2] + 1;
	    EndPos := StartPos + Result[1] - 1;
	    EXPORT MaxStr := Str1[StartPos..EndPos];
	END;
END;
