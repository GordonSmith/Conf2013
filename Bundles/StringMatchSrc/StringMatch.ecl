IMPORT $.CPP;

EXPORT StringMatch := MODULE, FORWARD
	IMPORT Std;
		EXPORT Bundle := MODULE(Std.BundleBase)
		EXPORT Name := 'StringMatch';
		EXPORT Description := 'Common Algorithms used to measure "Closeness"/"Distance" of strings.';
		EXPORT Authors := ['Gordon Smith'];
		EXPORT License := 'http://www.apache.org/licenses/LICENSE-2.0';
		EXPORT Copyright := 'Copyright (C) 2013 HPCC Systems';
		EXPORT DependsOn := [];
		EXPORT Version := '1.0.0';
	END;
	
	/**
     * A collection of distance measuring algorithms.
     *
     * @return A module exporting distance measuring functions.
     */
   	EXPORT Distance := MODULE
		/**
	   	 * @see <a href="http://en.wikipedia.org/wiki/Hamming_distance">Wikipedia</a>
		 */
		EXPORT Hamming(STRING Str1, STRING Str2) := MODULE
			/**	
		   	 * @return Distance between two strings.
			 */
			EXPORT Result := CPP.Hamming(Str1, Str2);
		END;
	  
		/**
	   	 * @see <a href="http://en.wikipedia.org/wiki/Levenshtein_distance">Wikipedia</a>
	   	 *
	   	 * Algorithm ported from <a href="http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance">WikiBooks</a>
		 */
		EXPORT Levenshtein(STRING Str1, STRING Str2) := MODULE

			/**	
		   	 * @return Distance between two strings.
			 */
			EXPORT Result := CPP.Levenshtein(Str1, Str2);
		END;
	  
		/**
	   	 * @see <a href="http://en.wikipedia.org/wiki/Sequence_alignment">Wikipedia</a>
	   	 *
	   	 * Algorithm ported from <a href="http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance">Wikipedia</a>
		 */
		EXPORT OptimalStringAlignment(STRING Str1, STRING Str2) := MODULE
			/**	
		   	 * @return Distance between two strings.
			 */
			EXPORT Result := CPP.OptimalStringAlignment(Str1, Str2);
		END;
		
		/**
	   	 * @see <a href="http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance">Wikipedia</a>
	   	 *
	   	 * Algorithm ported from <a href="http://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance">Wikipedia</a>
		 */
		EXPORT DamerauLevenshtein(STRING Str1, STRING Str2) := MODULE
			/**	
		   	 * @return Distance between two strings.
			 */
			EXPORT Result := DamerauLevenshteinCPP(Str1, Str2);
		END;
		
		/**
	   	 * @see <a href="http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html">Siderites Blog</a>
	   	 *
	   	 * Algorithm ported from <a href="http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html">Siderites Blog</a>
		 */
		EXPORT Sift3B(STRING Str1, STRING Str2) := MODULE
			/**	
		   	 * @return Distance between two strings.
			 */
			EXPORT Result := CPP.Sift3B(Str1, Str2);
		END;
	END;

	/**
   	 * @see <a href="http://en.wikipedia.org/wiki/Longest_common_subsequence_problem">Wikipedia</a>
   	 *
   	 * Algorithm ported from <a href="http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_subsequence">WikiBooks</a>
	 */
	EXPORT LongestCommonSubsequence(STRING Str1, STRING Str2) := MODULE
		/**	
	   	 * @return Longest Common Subsequence (String).
		 */
		EXPORT Result := CPP.LongestCommonSubsequence(Str1, Str2);
	END;
  
	/**
   	 * @see <a href="http://en.wikipedia.org/wiki/Longest_common_substring_problem">Wikipedia</a>
   	 *
   	 * Algorithm ported from <a href="http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Longest_common_substring">WikiBooks</a>
	 */
	EXPORT LongestCommonSubstring(STRING Str1, STRING Str2) := MODULE
		SHARED ResultSet := CPP.LongestCommonSubstring(Str1, Str2);
		/**	
	   	 * @return Longest Common Substring Length.
		 */
	    EXPORT ResultLength := ResultSet[1];
	    StartPos := ResultSet[2] + 1;
	    EndPos := StartPos + ResultLength - 1;
		/**	
	   	 * @return Longest Common Substring (String).
		 */
	    EXPORT Result := Str1[StartPos..EndPos];
	END;
	
	EXPORT Example := MODULE	
		SampleRecord := record
		  varstring Str1;
		  varstring Str2;
		end;
		SampleDataset := dataset([
			{'', ''},
			{'', 'Grodox'},
			{'Gordon', ''},
			{'123456', '123'},
			{'123', '123456'},
			{'Gordon', 'Grodox'},
			{'The lazy dog jumped over the fox', 'A lazy fox jumped over the dog'},
			{'This Has', 'No_Common'}
			], SampleRecord);
		LongestCommonSubstringRecord := record
		  integer4 len;
		  varstring str;
		end;
		ExampleRecord := record
		  varstring Str1;
		  varstring Str2;
		  integer4 hammingDistance;
		  integer4 levenshteinDistance;
		  integer4 damerauLevenshteinDistance;
		  integer4 optimalStringAlignmentDistance;
		  real4 sift3BDistance;
		  varstring longestCommonSubsequence;
		  LongestCommonSubstringRecord longestCommonSubstring;
		end;
		ExampleRecord toExampleRecord(SampleRecord l) := transform
			self.hammingDistance := Distance.Hamming(l.Str1, l.Str2).Result;
			self.levenshteinDistance := Distance.Levenshtein(l.Str1, l.Str2).Result;
			self.damerauLevenshteinDistance := Distance.DamerauLevenshtein(l.Str1, l.Str2).Result;
			self.optimalStringAlignmentDistance := Distance.OptimalStringAlignment(l.Str1, l.Str2).Result;
			self.sift3BDistance := Distance.Sift3B(l.Str1, l.Str2).Result;
		  	self.longestCommonSubsequence := LongestCommonSubsequence(l.Str1, l.Str2).Result;
		  	lcs := LongestCommonSubstring(l.Str1, l.Str2);
		  	self.longestCommonSubstring.len := lcs.ResultLength;
		  	self.longestCommonSubstring.str := lcs.Result;
			self := l;
		end;
		EXPORT Result := project(SampleDataset, toExampleRecord(left));
	END;	
END;
